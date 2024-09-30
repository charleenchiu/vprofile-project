# vprofile-project
vprofile-project

## 流程
### 手動在AWS建一EC2，使用Ubuntu OS，命名為JenkinsServer
- 建AWS EC2 Ubuntu JenkinsServer，Instance Type 用t2.micro
- 建一最簡單的Jenkinsfile，copy past 到pipeline code
- 試Jenkinsfile能跑
- 為此EC2建立映像檔(Image)
- 可Terminate此台EC2，或繼續使用做下一階段

### Jenkins + GitHub
- Jenkins 預設有安裝Git，所以不用安裝Git及Plugin
- 在GitHub帳戶設定/開發者 中申請Token
- 若JenkinsServer已Terminate，從AMI中選擇上階段建立留存的AMI來Langch一台新的EC2。留意VCP、Subnet、Sercurity Group、Internet Interface的設定
- 在JenkinsServer上加credential：AccountPassword，password填從GitHub取得的Token
- 將jenkinsfile的來源改成SCM，拉取存在GitHub上的jenkinsfile
- 測試Jenkinsfile能跑

### Jenkins + GitHub + Terraform
- SSH到JenkinsServer上，安裝Terraform
- http://我的IP:8080連到Jenkins，plugin安裝terraform
- 在Jekinsfile加一個stage，使能執行terraform -version，寫出output訊息

### Jenkins + GitHub + Terraform -> 建一AWS EC2，名為Kops
#### 單一Terraform檔案建置一台單純的EC2
- 寫一Terraform file，用來建立一台最簡單的EC2
- 修改Jenkinsfile，使能執行Terraform file建置AWS Resource
- 這時擔任JenkinsServer的EC2要用t2.small的Instance Type建立，才能執行在pipeline中執行建立另一台EC2
- 在Jenkins上安裝aws相關外掛
- 執行Jenkins Build，確認Terraform file有成功建立AWS EC2
- 清除Terraform的測試結果

#### Ansible檔案設定EC2
- 在JenkinsServer上安裝Ansible

●改Terraform file，建立AWS EC2 Ubuntu SornarQube Server、Kops Server
●執行Jenkinsfile，確認Terraform file有成功建立AWS Resource
●逐行確認能安裝這兩種Server，各寫UserData
●看能否用Ansible做UserData的設定
●清除Terraform的測試結果

#### 多Terraform檔案(組合)建置一台有SG等設定的EC2
- 將Terraform檔案拆成各組成，參數化
- 修改Jenkinsfile，使能執行Terraform file組，建置AWS Resource
- 執行Jenkins Build，確認Terraform file有成功建立AWS Resources
- 清除Terraform的測試結果



●寫Docker檔，建立Docker Image

※上傳ECR時，使用Docker 憑證助手
      這個警告信息表示 Docker 將您的登錄密碼未加密地存儲在 `/var/lib/jenkins/.docker/config.json` 文件中。這可能會帶來安全風險，因為未加密的密碼可能會被未經授權的用戶訪問。
      
      為了提高安全性，您可以配置 Docker 憑證助手（credential helper）來管理您的 Docker 登錄憑證。這樣，您的密碼將不會以未加密的形式存儲在配置文件中。
      
      以下是配置 Docker 憑證助手的步驟：
      
      1. **安裝 Docker 憑證助手**：
          - 根據您的操作系統，安裝適當的 Docker 憑證助手。例如，對於 Linux，您可以使用 `docker-credential-pass`：
            ```sh
            sudo apt-get install pass
            ```
      
      2. **配置 Docker 使用憑證助手**：
          - 編輯或創建 Docker 配置文件（通常位於 `~/.docker/config.json`），並添加以下內容：
            ```json
            {
                "credsStore": "pass"
            }
            ```
          - 這樣，Docker 將使用 `pass` 憑證助手來管理登錄憑證。
      
      3. **重新登錄到 ECR**：
          - 使用 Docker 憑證助手重新登錄到 ECR：
            ```sh
            aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 167804136284.dkr.ecr.us-east-1.amazonaws.com
            ```
      
      這樣，您的登錄憑證將由憑證助手管理，不會以未加密的形式存儲在配置文件中。
      
      如果您有任何其他問題或需要進一步的幫助，請隨時告訴我！

# ECR、ECS：
- 1.用Terraform建立2台EC2：一台作為Jenkins Server，另一台作為Sonar Server；還有建立ECS
- 2. 在Jenkins Server上執行jenkinsfile來：用Sonar做程式碼分析；建立Docker Image，並上傳到ECR，Deploy到ECS


●寫Helm檔

●用Jenkins Deploy 這些Image到Kops (K8s) Server

===========================================================================================
【階段2. 用AWS EKS及 Code Pipeline做同樣的專案】



===========================================================================================
【階段3. 用Jenkins 及 k8s 做EKS最複雜的專案】

===========================================================================================

【階段4. 用AWS EKS及 Code Pipeline做EKS最複雜的專案】

