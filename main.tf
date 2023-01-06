## Config Management 모듈 호출
module "config_management" {
  depends_on   = [aws_ami_launch_permission.bastion]
  count        = var.use_config_mgmt ? 1 : 0
  source       = "app.terraform.io/LG-uplus/configsvr/aws"
  version      = "2.0.11"
  env          = var.env
  project_name = var.pjt
  vpc_id       = aws_vpc.this.id
  subnet_ids   = data.aws_subnets.config_mgmt.ids

  # 옵션 파라미터 호출 입력이 없을경우 default 값으로 생성
  instance_count = local.is_dev ? 1 : 2 # 개발기의 경우 1인스턴스 사용, 검수/상용시 2개 인스턴스 생성
  #ami_ownerid = "945142638813" # UCMP 제공 Custom AMI Owner의 Account ID 입력. 별도 AMI를 사용하고 싶다면 Owner의 ID를 입력하여 사용
  #region = "ap-northeast-2" # 리전 ID 정보 입력
  #config_instance_type = "t2.micro" # EC2 인스턴스 타입 정보이며, 고사양 사용필요시 타입정보 입력
  #git_organization = var.project_name # Config Management 의 Application 이 구성되어 있는 Git 의 Organization 명 UCMP 사용시 project 명과 동일하게 자동 구성
  #ssh_key_name = "${var.env}-${var.project_name}-key" # 이미 생성이 되어 있는 키 사용 필요시 키 명 입력
  #artifact_enable = true # EC2용 Artifac 저장용 S3 가 이미 있다면 false, config management 서버용으로 최초 생성시 true 설정
}
