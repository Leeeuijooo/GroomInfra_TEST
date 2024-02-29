#!/bin/bash

echo "ebs_csi_driver 애드온 설치"

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

echo aws-ebs-csi-driver 신뢰정책 생성

cat >aws-ebs-csi-driver-trust-policy.json <<EOF
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
          "oidc.eks.$REGION.amazonaws.com/id/$oidc_id:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

sleep 3

echo aws-ebs-csi-driver 역할 생성

aws iam create-role \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json" &

sleep 2

echo aws-ebs-csi-driver 정책과 역할을 연결

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name AmazonEKS_EBS_CSI_DriverRole

sleep 2

echo csi driver 애드온 설치

aws eks create-addon --cluster-name eks_name --addon-name aws-ebs-csi-driver \
  --service-account-role-arn arn:aws:iam::$arn_id:role/AmazonEKS_EBS_CSI_DriverRole

sleep 3
