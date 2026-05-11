if ENV["S3_PUBLIC_URL"].present? && ENV["S3_ENDPOINT"].present?
  require "active_storage/service/s3_service"

  ActiveStorage::Service::S3Service.prepend(Module.new do
    private

    def private_url(key, **options)
      url = super
      url.sub(ENV["S3_ENDPOINT"], ENV["S3_PUBLIC_URL"])
    end
  end)
end
