# vprofile-project
vprofile-project

## 流程
### 手動在AWS建一EC2，使用Ubuntu OS，命名為JenkinsServer
- 建AWS EC2 Ubuntu JenkinsServer
- 建一最簡單的Jenkinsfile，copy past 到pipeline code
- 試Jenkinsfile能跑

### Jenkins + GitHub
- Jenkins 預設有安裝Git，所以不用安裝Git及Plugin
- 在GitHub帳戶設定/開發者 中申請Token
- 在JenkinsServer上加credential：GitHub Token
- 將jenkinsfile的來源改成SCM，拉取存在GitHub上的jenkinsfile
- 測試Jenkinsfile能跑

### Jenkins + GitHub + Terraform
- SSH到JenkinsServer上，安裝Terraform
- http://我的IP:8080連到Jenkins，plugin安裝terraform
- 在Jekinsfile加一個stage，使能執行terraform -version，寫出output訊息

### Jenkins + GitHub + Terraform -> 建一AWS EC2，名為Kops
#### 單一Terraform檔案建置一台單純的EC2
- 在Jenkins上安裝aws相關外掛
- 寫一最簡單建立EC2的Terraform file
- 修改Jenkinsfile，使能執行Terraform file建置AWS Resource
- 執行Jenkins Build，確認Terraform file有成功建立AWS EC2
- 清除Terraform的測試結果

#### 多Terraform檔案(組合)建置一台有SG等設定的EC2
- 將Terraform檔案拆成各組成，參數化
- 修改Jenkinsfile，使能執行Terraform file組，建置AWS Resource
- 執行Jenkins Build，確認Terraform file有成功建立AWS Resources
- 清除Terraform的測試結果

#### Ansible檔案設定EC2
- 

●改Terraform file，建立AWS EC2 Ubuntu SornarQube Server、Kops Server
●執行Jenkinsfile，確認Terraform file有成功建立AWS Resource
●逐行確認能安裝這兩種Server，各寫UserData
●看能否用Ansible做UserData的設定
●清除Terraform的測試結果

●寫Docker檔，建立Docker Image

●寫Helm檔

●用Jenkins Deploy 這些Image到Kops (K8s) Server

===========================================================================================
【階段2. 用AWS EKS及 Code Pipeline做同樣的專案】



===========================================================================================
【階段3. 用Jenkins 及 k8s 做EKS最複雜的專案】

===========================================================================================

【階段4. 用AWS EKS及 Code Pipeline做EKS最複雜的專案】

