locals {
  # network
  default_tag          = "${var.env}-${var.pjt}"
  is_dev               = (var.env == "dev")
  is_external_ip_exist = length(var.external_ip) > 0

  # bastion security group
  bastion_ingress_rules = flatten(try([
    for sg_name, sg_value in var.bastion_security_group : [
      for k, v in sg_value.ingress : [
        merge({ name = sg_name }, v)
      ]
    ]
  ], []))

  bastion_egress_rules = flatten(try([
    for sg_name, sg_value in var.bastion_security_group : [
      for k, v in sg_value.egress : [
        merge({ name = sg_name }, v)
      ]
    ]
  ], []))

  folder_per_bucket = flatten(try([
    for bucket_name, v in var.s3 : [
      for folder in v.folder_name : merge(
        { key = "${bucket_name}.${folder}" },
        { bucket_id = aws_s3_bucket.log[bucket_name].id },
        { folders = folder }
      )
    ]
  ], []))

  // EFS
  efs_per_subnet = flatten(try([
    for k_efs, v_efs in var.efs : [
      for v_mnt in v_efs.subnet_name :
      merge(
        { key = "${k_efs}.${v_mnt}" },
        { efs_id = aws_efs_file_system.log[k_efs].id },
        { security_group_name = v_efs.security_group_name },
        { subnet_name = v_mnt }
      )
    ]
  ], []))

  # efs security group
  efs_ingress_rules = flatten(try([
    for sg_name, sg_value in var.efs_security_group : [
      for k, v in sg_value.ingress : [
        merge({ name = sg_name }, v)
      ]
    ]
  ], []))

  efs_egress_rules = flatten(try([
    for sg_name, sg_value in var.efs_security_group : [
      for k, v in sg_value.egress : [
        merge({ name = sg_name }, v)
      ]
    ]
  ], []))

  # s3
  # s3 = var.s3 != {} ? toset(concat(var.s3, var.default_s3)) : var.default_s3
  # s3 = var.s3 != {} ? merge(var.s3, var.default_s3) : var.default_s3
  s3 = merge({ for k, v in var.s3 : k => {
    allowed_headers = try(v.allow_headers, var.allowed_headers),
    allowed_methods = try(v.allowed_methods, var.allowed_methods),
    allowed_origins = try(v.allowed_origins, var.allowed_origins),
    max_age_seconds = try(v.max_age_seconds, var.max_age_seconds),
    status          = try(v.status, var.version_enable),
    acl             = try(v.acl, var.acl)
    } },
    { for k1, v1 in var.default_s3 : k1 => {
      allowed_headers = try(v1.allow_headers, var.allowed_headers),
      allowed_methods = try(v1.allowed_methods, var.allowed_methods),
      allowed_origins = try(v1.allowed_origins, var.allowed_origins),
      max_age_seconds = try(v1.max_age_seconds, var.max_age_seconds),
      status          = try(v1.status, var.version_enable),
      acl             = try(v1.acl, var.acl)
    } }
  )

  routing_table = flatten(try([
    for ip in var.external_ip : [
      for key, zone in var.zones : merge(
        { key = key },
        { ip = ip }
      )
    ]
  ], []))

  #flatten(try([for ip in var.external_ip : [for key, zone in var.zones : merge({ key = key }, { ip = ip })]], []))

}
