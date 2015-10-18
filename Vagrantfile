Vagrant.configure("2") do |config|
  config.vm.box = "dummy"

  config.vm.provider :aws do |aws, override|
    aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 50 }]
    aws.access_key_id = ENV['ACCESS_KEY_ID']
    aws.secret_access_key = ENV['SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['KEYPAIR_NAME']

    aws.ami = "ami-37673152"

    aws.associate_public_ip = true
    aws.subnet_id = ENV['SUBNET_ID']
    aws.region = "us-east-1"

    aws.instance_type = "c3.8xlarge"
    aws.terminate_on_shutdown = true

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = ENV['SSH_KEY']
  end
end