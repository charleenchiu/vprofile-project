# vprofile-project
vprofile-project

## 流程
01. 建AWS EC2 Ubuntu JenkinsServer
02. 建一最簡單的Jenkinsfile能跑
●試Jenkinsfile能跑

●建一最簡單的Terraform file
●改Jekinsfile使跑Terraform file
●執行Jenkinsfile，確認Terraform file有成功建立AWS Resource
●清除Terraform的測試結果

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

