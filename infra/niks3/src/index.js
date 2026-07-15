import { Container } from "@cloudflare/containers";
import { env as workerEnv } from "cloudflare:workers";

export class Niks3Container extends Container {
  defaultPort = 5751;
  sleepAfter = "15m";
  // Default pingEndpoint ("ping") probes bare "/", which niks3 answers with a
  // 301 to the external https cache URL — the readiness check then trips the
  // https-not-supported rejection trying to follow that redirect. Niks3 has a
  // real unconditional-200 health route at /health; route the probe there
  // instead, per the documented "host/path" pingEndpoint format.
  pingEndpoint = "localhost/health";

  envVars = {
    NIKS3_API_TOKEN: workerEnv.NIKS3_API_TOKEN,
    NIKS3_CACHE_URL: workerEnv.NIKS3_CACHE_URL,
    NIKS3_DB: workerEnv.NIKS3_DB,
    NIKS3_S3_ACCESS_KEY: workerEnv.NIKS3_S3_ACCESS_KEY,
    NIKS3_S3_BUCKET: "niks3",
    NIKS3_S3_BUCKET_LOOKUP: "path",
    NIKS3_S3_ENDPOINT: workerEnv.NIKS3_S3_ENDPOINT,
    NIKS3_S3_REGION: "auto",
    NIKS3_S3_SECRET_KEY: workerEnv.NIKS3_S3_SECRET_KEY,
    NIKS3_S3_USE_SSL: "true",
    NIKS3_SIGN_KEY: workerEnv.NIKS3_SIGN_KEY,
  };
}

export default {
  fetch(request, env) {
    // A fixed Durable Object name gives Niks3 one authoritative server process.
    return env.NIKS3_CONTAINER.getByName("primary").fetch(request);
  },
};
