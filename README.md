# 🛡️ DevSecOps Pipeline — Multi-Stage Docker + Trivy

## Project Structure

```
devsecops-app/
├── src/
│   └── index.js          ← Express app (Dev's work)
├── tests/
│   └── app.test.js       ← Unit tests (Dev's work)
├── Dockerfile            ← Multi-stage build (Dev's work)
├── .dockerignore         ← Security hygiene (Dev's work)
├── package.json          ← Pinned deps (Dev's work)
└── .github/
    └── workflows/
        └── pipeline.yml  ← ⚙️ YOUR PART (DevOps)
```

---

## 🏗️ Multi-Stage Build Explained

| Stage | Base | Purpose | Kept in final? |
|-------|------|---------|----------------|
| `deps` | node:20-alpine | Install all deps | ❌ |
| `test` | deps | Run unit tests | ❌ |
| `builder` | node:20-alpine | Prod deps only | ❌ |
| `production` | node:20-alpine | Final lean image | ✅ |

**Why multi-stage?**
- Final image has NO dev tools, NO test files, NO source maps
- Smaller attack surface for Trivy to scan
- If tests fail in `test` stage → build stops → nothing gets deployed

---

## 🔒 Security Practices in the Dockerfile

1. **`node:20-alpine`** — minimal base, fewer pre-installed packages = fewer CVEs
2. **Non-root user** — `appuser` runs the process, not `root`
3. **`npm ci --omit=dev`** — production deps only in final image
4. **HEALTHCHECK** — Docker monitors container health automatically
5. **`.dockerignore`** — `.env` files never baked into image

---

## ⚙️ Your DevOps Part (GitHub Actions)

Your pipeline should:

```
[Push to main]
      │
      ▼
  ┌─────────┐
  │  BUILD  │  docker build --target production -t myapp .
  └────┬────┘
       │
       ▼
  ┌─────────┐
  │  SCAN   │  trivy image --exit-code 1 --severity HIGH,CRITICAL myapp
  └────┬────┘
       │ (fails here if vulnerabilities found)
       ▼
  ┌─────────┐
  │  PUSH   │  docker push (only if scan passes)
  └─────────┘
```

### Trivy flags to know:
- `--exit-code 1` → fail the pipeline on findings
- `--severity HIGH,CRITICAL` → only fail on serious issues
- `--ignore-unfixed` → skip CVEs with no patch yet

---

## 🧪 Test locally

```bash
# Build the image
docker build -t devsecops-demo .

# Run it
docker run -p 3000:3000 devsecops-demo

# Hit the health endpoint
curl http://localhost:3000/health

# Scan manually with Trivy (install trivy first)
trivy image devsecops-demo
```
