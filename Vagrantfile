Vagrant.configure("2") do |config|
  config.vm.box = "dummy"

  config.vm.provider :aws do |aws, override|
    aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 50 }]
    aws.access_key_id = ENV['ACCESS_KEY_ID']
    aws.secret_access_key = ENV['SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['KEYPAIR_NAME']

    aws.ami = "ami-37673152"

    aws.associate_public_ip = true
    aws.ssh_host_attribute = :public_ip_address
    aws.subnet_id = ENV['SUBNET_ID']
    aws.region = "us-east-1"

    # AWESOME POWAH!
    aws.instance_type = "c4.8xlarge"
    aws.terminate_on_shutdown = true

    aws.security_groups = [ ENV['SECURITY_GROUP'] ]

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = ENV['SSH_KEY']
    override.nfs.functional = false

    $script = <<SCRIPT
. ~/.bashrc
if test -f "#{ENV['INPUT_FILE']}"; then exit;fi
aws s3 cp "s3://ryanbreen.media/#{ENV['INPUT_FILE']}" .
HandBrakeCLI -e x265 -f mkv --x265-preset fast --h265-profile main --h265-level 4.1 -i "#{ENV['INPUT_FILE']}" -o "#{ENV['TARGET_FILE']}"
aws s3 cp "#{ENV['TARGET_FILE']}" s3://ryanbreen.media/
SCRIPT

    config.vm.provision "shell", inline: $script, privileged: false

  end
end