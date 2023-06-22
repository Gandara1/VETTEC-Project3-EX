resource "aws_security_group_rule" "eks_to_rds" {
  security_group_id        = aws_db_instance.rds_instance.vpc_security_group_ids[0]
  source_security_group_id = module.eks.cluster_security_group_id
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
}