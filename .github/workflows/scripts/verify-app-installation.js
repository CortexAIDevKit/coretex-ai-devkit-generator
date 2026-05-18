const crypto = require("crypto");

function base64url(input) {
  return Buffer.from(input)
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

module.exports = async ({ core }) => {
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iat: now - 60,
    exp: now + 10 * 60,
    iss: process.env.APP_ID,
  };

  const encodedHeader = base64url(JSON.stringify(header));
  const encodedPayload = base64url(JSON.stringify(payload));
  const data = `${encodedHeader}.${encodedPayload}`;

  const signer = crypto.createSign("RSA-SHA256");
  signer.update(data);
  const signature = signer
    .sign(process.env.PRIVATE_KEY, "base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const jwt = `${data}.${signature}`;
  const org = process.env.TARGET_ORG;

  const response = await fetch(
    `https://api.github.com/orgs/${encodeURIComponent(org)}/installation`,
    {
      method: "GET",
      headers: {
        authorization: `Bearer ${jwt}`,
        accept: "application/vnd.github+json",
        "user-agent": `${process.env.APP_SLUG}-workflow`,
      },
    }
  );

  if (response.status === 404) {
    core.setFailed(
      `GitHub App ${process.env.APP_SLUG} is not installed on ${org}`
    );
    return;
  }

  if (!response.ok) {
    const body = await response.text();
    throw new Error(
      `Installation lookup failed: ${response.status} ${body}`
    );
  }

  const installation = await response.json();
  core.info(`✅ ${process.env.APP_SLUG} installed on ${org}`);
  core.setOutput("installation_id", String(installation.id));
};
