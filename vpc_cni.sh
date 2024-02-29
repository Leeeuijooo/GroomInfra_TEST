#!/bin/bash

echo "vpc_cni 애드온 설치"

# EKS 클러스터의 이름
cluster_name="eks_name"

# 클러스터 ARN 조회
cluster_arn=$(aws eks describe-cluster --name $cluster_name --query "cluster.arn" --output text)

# 계정 번호 추출
arn_id=$(echo $cluster_arn | cut -d':' -f5)

echo "$arn_id"


oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

echo "$oidc_id"

sleep 1

REGION="ap-northeast-2"

echo "$REGION"

echo "AmazonEKSVPCCNIRole 신뢰정책 생성"

cat >vpc-cni-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$arn_id:oidc-provider/oidc.eks.$REGION.amazonaws.com/id/$oidc_id"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.$REGION.amazonaws.com/id/$oidc_id:aud": "sts.amazonaws.com",
                    "oidc.eks.$REGION.amazonaws.com/id/$oidc_id:sub": "system:serviceaccount:kube-system:aws-node"
                }
            }
        }
    ]
}
EOF

sleep 2

echo "AmazonEKSVPCCNIRole 역할 생성"

aws iam create-role \
  --role-name AmazonEKSVPCCNIRole \
  --assume-role-policy-document file://"vpc-cni-trust-policy.json" &

sleep 2

echo "필요한 IAM 정책을 역할에 연결"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --role-name AmazonEKSVPCCNIRole

sleep 2

echo "이전에 생성한 IAM 역할의 ARN을 사용하여 aws-node 서비스 계정에 주석을 추가"

kubectl annotate serviceaccount \
    -n kube-system aws-node \
    eks.amazonaws.com/role-arn=arn:aws:iam::$arn_id:role/AmazonEKSVPCCNIRole &

sleep 2

echo "annotation을 위하여 aws-node 데몬셋 pod 재배포"

kubectl delete Pods -n kube-system -l k8s-app=aws-node

sleep 12

echo "모든 Pods가 다시 시작되었는지 확인"

kubectl get pods -n kube-system -l k8s-app=aws-node

sleep 2

echo "현재 설치된 추가 기능의 구성을 저장 - 백업용도"

kubectl get daemonset aws-node -n kube-system -o yaml > aws-k8s-cni-old.yaml

sleep 2

echo "vpc-cni 애드온 설치"

aws eks create-addon --cluster-name $cluster_name --addon-name vpc-cni --addon-version  v1.11.4-eksbuild.1 \
    --service-account-role-arn arn:aws:iam::$arn_id:role/AmazonEKSVPCCNIRole
