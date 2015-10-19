
def usage
  puts "process_video.rb [video filename]"
  exit
end

require 'fileutils'
require "highline/import"

usage unless ARGV.length == 1

file = ARGV[0]
target_file = "#{File.basename(file, File.extname(file))}.x265.mkv"
fq_target_file = File.join(File.dirname(file), target_file)
puts "Converting #{file} to #{target_file}"

# If the file hasn't already been copied to S3, do so now.
s3_size = `aws s3 ls "s3://ryanbreen.media/#{File.basename(file)}" | cut -d\\  -f 3`
local_size = `ls -l "#{file}" | cut -d\\  -f 8`
if s3_size != local_size
  # Copy movie to S3
  system "aws s3 cp \"#{file}\" s3://ryanbreen.media/"
end

# Run VM
system({"INPUT_FILE" => File.basename(file), "TARGET_FILE" => target_file}, "vagrant up --provider=aws")

# Destroy VM
system "vagrant destroy -f"

# Copy movie down
system "aws s3 cp \"s3://ryanbreen.media/#{target_file}\" \"#{File.dirname(file)}\""

# Delete original and source from s3
system "aws s3 rm \"s3://ryanbreen.media/#{target_file}\""
system "aws s3 rm \"s3://ryanbreen.media/#{File.basename(file)}\""

FileUtils.touch fq_target_file, :mtime => File.mtime(file)

vlc = fork do
  exec "open \"#{fq_target_file}\""
end

Process.detach(vlc)

new_file = "#{File.basename(file, File.extname(file))}.mkv"
fq_new_file = File.join(File.dirname(file), new_file)

input = ask "Should we replace the source file and rename the new version to? (yes/no)"
if input == "yes"
  File.delete file
  File.rename fq_target_file, fq_new_file
end