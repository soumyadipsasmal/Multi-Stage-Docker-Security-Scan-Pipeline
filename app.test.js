const request = require("supertest");
const app = require("../src/index");

describe("App Routes", () => {
  it("GET / returns welcome message", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe("DevSecOps Demo App 🚀");
  });

  it("GET /health returns status ok", async () => {
    const res = await request(app).get("/health");
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe("ok");
    expect(res.body.timestamp).toBeDefined();
  });
});
