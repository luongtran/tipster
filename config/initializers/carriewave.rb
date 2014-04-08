CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider                         => 'Google',
      :google_storage_access_key_id     => 'GOOGKMDKBBMNX6Q6NF36',
      :google_storage_secret_access_key => 'kk2x34nLSjY2oPw72vQvDoQKOoIFPuDjjloKHG26'
  }
  #config.fog_directory = 'avatars'
end