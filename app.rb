require 'rubygems' 
require 'bundler'
Bundler.require

CONFIG = YAML.load_file("config.yml")

get '/' do
  return %Q{
    <form action="upload" method="post" accept-charset="utf-8" enctype="multipart/form-data">
      <div>
        <input type="file" name="file" value="" id="file">
      </div>
      <div>
        <input type="text" name="prefix" value="" id="prefix">
      </div>
      <div>
        <input type="submit" value="Upload &uarr;">
      </div>
    </form>
  }
end
 
post '/upload' do
  file       = params[:file][:tempfile]
  filename   = params[:file][:filename]
  prefix     = params[:prefix]
  remote_name = "#{prefix}/#{Time.now.to_i}_#{filename}"
  
  AWS::S3::Base.establish_connection!(
    :access_key_id     => CONFIG["s3"]["key"],
    :secret_access_key => CONFIG["s3"]["secret"]
  )
  AWS::S3::S3Object.store(
    "#{prefix}/#{Time.now.to_i}_#{filename}",
    open(file.path),
    CONFIG["s3"]["bucket"]
    # :access => :public_read
  )

  return "success"
end
