# encoding: utf-8
module CarrierWave
  module Storage
    class Qiniu < Abstract
      def store!(file)
        success = QiniuFile.new(uploader, uploader.store_path).tap do |qiniu_file|
          qiniu_file.store(file)
        end
        raise "无法上传文件到七牛" unless success

        success
      end

      def cache!(file)
        success = QiniuFile.new(uploader, uploader.cache_path).tap do |qiniu_file|
          qiniu_file.store(file)
        end
        raise "无法上传文件到七牛" unless success

        success
      end

      def retrieve!(identifier)
        QiniuFile.new(uploader, uploader.store_path(identifier))
      end

      def retrieve_from_cache!(identifier)
        QiniuFile.new(uploader, uploader.cache_path(identifier))
      end

      ##
      # Deletes a cache dir
      #
      def delete_dir!(path)
        path = Rack::Utils.escape_path(path)
        QiniuFile.new(uploader, uploader.store_path).tap do |qiniu_file|
          conn = qiniu_file.send(:qiniu_connection)
          result = conn.list({ prefix: path })

          raise result["error"] if result.has_key?("error")

          keys = result["items"].map {|it| it["key"]}
          conn.batch_delete(keys)
        end
      end

      def clean_cache!(seconds)
        # 如果缓存目录在云端,建议使用七牛云存储的生命周期设置, 以减少主动 API 调用次数
        raise 'Use Qiniu Object Lifecycle Management to clean the cache'
      end
    end
  end
end
