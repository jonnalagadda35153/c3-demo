Perfect ✅ — Let’s produce a **complete and print-ready Markdown version** of both guides.
Below you’ll find two full documents:

---

# 📘 **C3 Automated Terraform Correction Pipeline — Execution Guide**

---

## 🏗️ **Goal**

Build a **no-code AI-powered pipeline** in **n8n** that automatically:

1. Detects bad Terraform code from a branch
2. Uses OpenAI to correct and harden it
3. Writes fixes locally
4. Commits and pushes to a new branch
5. Creates a Pull Request (PR) automatically

---

## ⚙️ **Environment Setup**

| Requirement        | Description                                                                                                                           |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| **n8n**            | Desktop or Docker setup                                                                                                               |
| **Local Git Repo** | Mounted at `/workspace/c3-demo`                                                                                                       |
| **GitHub PAT**     | Classic token with `repo` scope                                                                                                       |
| **OpenAI API Key** | GPT-4o / GPT-5 access                                                                                                                 |
| **Git Config**     | Inside container run: <br> `git config --global user.name "your-github-user"` <br> `git config --global user.email "you@example.com"` |
| **Connectivity**   | Ensure GitHub API and OpenAI endpoints reachable                                                                                      |

---

## 🧩 **Workflow Structure**

| Step | Node                        | Purpose                                       |
| ---- | --------------------------- | --------------------------------------------- |
| 1    | **Trigger (Manual)**        | Start workflow manually                       |
| 2A   | **Git – Switch Branch**     | Checkout target (e.g. `demo-branch`)          |
| 2B   | **Git – Pull**              | Sync repo locally                             |
| 3A   | **HTTP GET Branch Head**    | Retrieve latest commit SHA                    |
| 3B   | **HTTP GET Commit Files**   | Fetch list of changed files                   |
| 3C   | **Code Node – Filter .tf**  | Keep only `.tf` files                         |
| 4A   | **HTTP GET File Content**   | Pull file content from GitHub API             |
| 4B   | **Code – Decode Base64**    | Decode file text                              |
| 5A   | **OpenAI Message a Model**  | Fix Terraform issues                          |
| 5B   | **Edit Fields**             | Extract filename, corrected code, branch name |
| 6A   | **Convert to File**         | Convert corrected text → binary               |
| 6B   | **Write File to Disk**      | Overwrite repo files                          |
| 6C   | **Git – Switch Branch**     | Create new branch `c3-fix-<sha>`              |
| 6D   | **Git – Add Files**         | Stage all corrected files                     |
| 6E   | **Git – Commit**            | Commit “C3: Automated Terraform fixes”        |
| 6F   | **Git – Push**              | Push new branch                               |
| 7A   | **Code – Build PR Payload** | Merge files → single PR item                  |
| 7B   | **HTTP POST – Create PR**   | Create pull request automatically             |

---

## 🧠 **Detailed Node Configurations**

---

### **Decode Base64 (Code Node)**

```javascript
return $input.all().map(i => {
  const content = i.json.content;
  const buff = Buffer.from(content, 'base64');
  return {
    json: {
      filename: i.json.name,
      body: buff.toString('utf8')
    }
  };
});
```

✅ This ensures **all Terraform files** are decoded, not just the first one.

---

### **OpenAI Model Node**

| Parameter     | Value                                                                     |
| ------------- | ------------------------------------------------------------------------- |
| Resource      | Text                                                                      |
| Operation     | Message a Model                                                           |
| Model         | GPT-4o-mini or GPT-5                                                      |
| System Prompt | `You are a precise Terraform reviewer fixing security and syntax errors.` |
| User Prompt   | `Review and correct the following Terraform file:`                        |
| Input         | `{{ $json.body }}`                                                        |
| Temperature   | 0                                                                         |

---

### **Edit Fields (Manual Mapping)**

| Field           | Expression                                                                  |
| --------------- | --------------------------------------------------------------------------- |
| **filename**    | `{{ $json.filename }}`                                                      |
| **branch_name** | `{{ "c3-fix-" + $items("GET Branch Head")[0].json.commit.sha.slice(0,7) }}` |
| **corrected**   | `{{ $json.output[0].content[0].text }}`                                     |

---

### **Convert to File**

| Setting                  | Value                |
| ------------------------ | -------------------- |
| Operation                | Convert to text file |
| Text Input Field         | `corrected`          |
| Put Output File in Field | `data`               |

---

### **Write File to Disk**

| Setting            | Value                                     |
| ------------------ | ----------------------------------------- |
| Operation          | Write file to disk                        |
| File Path          | `/workspace/c3-demo/{{ $json.filename }}` |
| Input Binary Field | `data`                                    |

---

### **Git – Switch Branch (Create New)**

| Option            | Example                   |
| ----------------- | ------------------------- |
| Operation         | Switch Branch             |
| Branch Name       | `{{ $json.branch_name }}` |
| Create if Missing | ✅ Enabled                 |

---

### **Git – Add Files**

| Field        | Value     |
| ------------ | --------- |
| Paths to Add | `.`       |
| Execute Once | ✅ Enabled |

---

### **Git – Commit**

| Message | `C3: Automated Terraform security fixes` |

---

### **Git – Push**

| Remote | origin |
| Branch | `{{ $json.branch_name }}` |
| Execute Once | ✅ Enabled |

---

### **Build PR Payload (Code Node)**

```javascript
const files = $items("Edit Fields").map(i => i.json.filename);
const branch = $items("Edit Fields")[0].json.branch_name;
return [{ json: { branch_name: branch, files } }];
```

---

### **Create PR (HTTP Request)**

| Setting           | Value                                                                                                                                                                                  |
| ----------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Method            | POST                                                                                                                                                                                   |
| URL               | `https://api.github.com/repos/<owner>/<repo>/pulls`                                                                                                                                    |
| Authentication    | Bearer Token (GitHub PAT)                                                                                                                                                              |
| Body Content Type | JSON                                                                                                                                                                                   |
| Fields            |                                                                                                                                                                                        |
| → `title`         | `C3: Automated Terraform security fixes`                                                                                                                                               |
| → `head`          | `{{ $json.branch_name }}`                                                                                                                                                              |
| → `base`          | `demo-branch`                                                                                                                                                                          |
| → `body`          | `{{ "✅ Automated Terraform fix for " + $json.files.join(", ") + "\\n\\nAll detected syntax and security issues were auto-corrected using GPT-5.\\n\\nBranch: " + $json.branch_name }}` |

---

### **Validation**

✅ Single PR created
✅ Branch named `c3-fix-<sha>`
✅ Includes all `.tf` files
✅ Contains AI-corrected secure Terraform code

---

# 🗣️ **C3 Automated Terraform Correction Workflow — Presentation Script**

---

## 🎯 **Opening (Storyline)**

> “Developers spend countless hours fixing Terraform lint, security issues, and syntax problems.
> Today I’ll demonstrate how an AI-driven, low-code workflow built in n8n automatically fixes Terraform code and raises a Pull Request — end to end.”

--- 

## 🧱 **Live Demo Flow**

1. **Show the Problem**

   * “Here’s a Terraform file with hardcoded AWS credentials and public S3 access.”
   * Display the file in VS Code.

2. **Run the Workflow**

   * “Now let’s run our C3 workflow in n8n. It pulls the latest repo state and inspects changed `.tf` files.”

3. **Decode and Fix**

   * “The workflow decodes base64 file content, sends it to OpenAI, and gets a corrected version.”

4. **Show AI Output**

   * Open the “Message a Model” node output:

     * The AI has removed hardcoded keys.
     * Added encryption, lifecycle rules, tags, and compliance structure.

5. **Git Automation**

   * “The corrected files are saved back, committed, and pushed into a new branch automatically.”

6. **Pull Request**

   * Switch to GitHub:

     * Open PR titled `C3: Automated Terraform security fixes`.
     * The PR body lists all `.tf` files fixed and the branch name.

7. **Highlight the Value**

   * “In minutes, we corrected multiple Terraform files without writing a single line of glue code.”

---

## 💬 **Key Talking Points**

| Category        | Talking Point                                         |
| --------------- | ----------------------------------------------------- |
| **Innovation**  | No-code orchestration (n8n) + AI remediation (OpenAI) |
| **Scalability** | Supports multiple files and repositories              |
| **Speed**       | Developers save hours per review cycle                |
| **Governance**  | Enforces IaC security and compliance automatically    |

---

## 🧠 **Optional Enhancements**

* Add `terraform fmt` or `tflint` validation nodes post-model.
* Auto-merge low-risk PRs after passing policy checks.
* Integrate Slack notifications for team visibility.

---

## 🏁 **Closing Script**

> “AI doesn’t replace developers — it removes friction.
> With this workflow, we’ve built an intelligent, low-code DevSecOps assistant that auto-reviews Terraform and enforces best practices — instantly.”
