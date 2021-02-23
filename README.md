# mediawiki
## Mediawiki implemntation using Terraform
### Architechture Diagram 
![Alt text](./files/mediawiki.jpeg?raw=true "Mediawiki implementation on AWS using Terraform")
### Prerequisites:

- AWS account with access keys and secret access key generated for same
- Terraform installed onto machine
- AWS cli installed onto machine
  
### Steps to implement mediawiki using terraform on aws account
1.Configure aws credentials on your machine
2.Clone this repo Mediawiki
3.Make sure you generate a ssh key using command ssh-keygen onto the server, the public key should be used while creating the instance Key, and private key should be used for accessing the instance. please refer SSH-KEYGEN

### Plan
```
terrform plan
```

### Apply
```
terraform apply
```

### Destroy
```
terraform destroy
```
