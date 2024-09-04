# vprofile-project
vprofile-project

●建AWS EC2 Ubuntu JenkinsServer
●建一最簡單的Jenkinsfile能跑
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


===========================================================================================
# Markdown syntax guide

## Headers

# This is a Heading h1
## This is a Heading h2
###### This is a Heading h6

## Emphasis

*This text will be italic*  
_This will also be italic_

**This text will be bold**  
__This will also be bold__

_You **can** combine them_

## Lists

### Unordered

* Item 1
* Item 2
* Item 2a
* Item 2b

### Ordered

1. Item 1
2. Item 2
3. Item 3
    1. Item 3a
    2. Item 3b

## Images

![This is an alt text.](/image/sample.webp "This is a sample image.")

## Links

You may be using [Markdown Live Preview](https://markdownlivepreview.com/).

## Blockquotes

> Markdown is a lightweight markup language with plain-text-formatting syntax, created in 2004 by John Gruber with Aaron Swartz.
>
>> Markdown is often used to format readme files, for writing messages in online discussion forums, and to create rich text using a plain text editor.

## Tables

| Left columns  | Right columns |
| ------------- |:-------------:|
| left foo      | right foo     |
| left bar      | right bar     |
| left baz      | right baz     |

## Blocks of code

```
let message = 'Hello world';
alert(message);
```

## Inline code

This web site is using `markedjs/marked`.



