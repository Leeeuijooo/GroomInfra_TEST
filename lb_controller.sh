#!/bin/bash

echo "lb-controller 설치"

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

echo "IAM 정책을 다운로드"

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json

sleep 3

echo "LB Controller IAM 정책 생성"
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

sleep 5

echo load-balancer-role-trust-policy.json 생성

cat >load-balancer-role-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$arn_id:oidc-provider/oidc.eks.ap-northeast-2.amazonaws.com/id/$oidc_id"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.$REGION.amazonaws.com/id/$oidc_id:aud": "sts.amazonaws.com",
                    "oidc.eks.$REGION.amazonaws.com/id/$oidc_id:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF

sleep 2

echo "IAM 역할 생성"
aws iam create-role \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --assume-role-policy-document file://"load-balancer-role-trust-policy.json" &

sleep 2

echo "Amazon EKS 관리형 IAM 정책을 IAM 역할에 연결"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::$arn_id:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name AmazonEKSLoadBalancerControllerRole

sleep 2

echo "controller-service-account.yaml 파일 생성"

cat >aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::$arn_id:role/AmazonEKSLoadBalancerControllerRole
EOF

echo 클러스터에서 Kubernetes 서비스 계정을 만들기
kubectl apply -f aws-load-balancer-controller-service-account.yaml
sleep 10

echo cert-manager 배포 시간이 약간 소요됩니다^^
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
sleep 40

echo "kubectl wait"
kubectl wait \
  --request-timeout=300s \
  -n cert-manager \
  --for=condition=Available deployment/cert-manager-webhook

echo "컨트롤러 설치"
curl -Lo v2_4_7_full.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_full.yaml
sleep 5

echo "YAML ServiceAccount 제거"
sed -i.bak -e '561,569d' ./v2_4_7_full.yaml
sleep 2

echo "클러스터 이름 대체"
sed -i.bak -e 's|your-cluster-name|eks_name|' ./v2_4_7_full.yaml
sleep 2

echo "파일 적용"
kubectl apply -f v2_4_7_full.yaml
sleep 5

echo "IngressClass 및 IngressClassParams 매니페스트 클러스터에 다운"
curl -Lo v2_4_7_ingclass.yaml https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.4.7/v2_4_7_ingclass.yaml
sleep 5

echo "클러스터에 매니페스트 적용"
kubectl apply -f v2_4_7_ingclass.yaml
sleep 10

echo "컨트롤러 설치 확인"
kubectl get deployment -n kube-system aws-load-balancer-controller
sleep 2
