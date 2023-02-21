# Linguagem declarativa

resource "aws_s3_bucket" "datalake" {
    #comentario para modificar o plan apos apply
  bucket = "${var.base_bucket_name}-${var.ambiente}-${var.numero_conta}"

  tags = {
    IES         = "IGTI"
    CURSO       = "EDC"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "acl_datalake" {
  bucket = aws_s3_bucket.datalake.id
  acl    = "private"
}



resource "aws_kms_key" "mykeykms_datalake" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}


resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_datalake" {
  bucket = aws_s3_bucket.datalake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}


resource "aws_s3_bucket_object" "codigo_spark" {
  bucket = aws_s3_bucket.datalake.id
  key    = "emr-code/pyspark/job_spark_from_tf.py"
  acl    = "private"
  source = "../job_spark.py"


  # etag é o controle de estado, toda vez que subir o terrraform vai verificar se houve alteração 
  # se não houver mudança não faz o depósito novamente
  
  etag = filemd5("../job_spark.py")
}

provider "aws" {
  region =  "${var.regiao}"
}