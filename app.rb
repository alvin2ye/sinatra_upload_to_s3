require 'rubygems' 
require 'bundler'
require 'yaml'
Bundler.require

CONFIG = YAML.load_file("config.yml")


class App < Sinatra::Base
  get '/' do
    "404"
  end
  
  get '/up' do
    return %Q{
      <html>
      <body>
      <form action="upload" method="post" accept-charset="utf-8" enctype="multipart/form-data">
      <p>
      <input type="file" name="file" value="" id="file">
      </p>
      <p>
      Prefix <input type="text" name="prefix" value="" id="prefix">
      </p>
      <p>
      Public <input type="checkbox" name="public" id="public">
      </p>
      <p>
      <input type="submit" value="Upload">
      </p>
      </form>
      </body>
      </html>
    }
  end
 
  post '/upload' do
    AWS::S3::Base.establish_connection!(
      :access_key_id     => CONFIG["s3"]["key"],
      :secret_access_key => CONFIG["s3"]["secret"]
    )
    
    file       = params[:file][:tempfile]
    filename   = params[:file][:filename]
    remote_name = "#{prefix}/#{Time.now.to_i}_#{filename}".gsub(" ", "_")
    AWS::S3::S3Object.store(remote_name, open(file.path), bucket, :access => access_perm)
    return params[:public] == "on" ? "success, #{cdn_url(remote_name)}" : "success"
  end
  
  def prefix
    prefix = params[:prefix]
    prefix = "_" if prefix.nil? || prefix.size == 0
    params[:public] == "on" ? "public/#{prefix}" : prefix
  end
  
  def bucket
    CONFIG["s3"]["bucket"]
  end
  
  def access_perm
    params[:public] == "on" ? :public_read : :private
  end
  
  def cdn_url(remote_name)
    # http://agi-backups.s3.amazonaws.com/public/1/1388022618_1.png
    # remote_name :  public/1/1388022618_1.png
    # result http://agi-public2.u.qiniudn.com/1/1388022618_1.png
    "http://agi-public2.u.qiniudn.com" + remote_name.gsub(/^public/, "")
  end
end