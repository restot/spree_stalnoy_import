DownloadJob = Struct.new(:url,:name) do

  def perform
      IO.copy_stream(open(url,
                          'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.183 Safari/537.36 Vivaldi/1.96.1147.36',
                          'Accept' => 'text/html',
                          'Accept-Encoding'=> 'gzip'), Rails.root.join('yml', name.to_s ))
  end

     def reschedule_at(current_time, attempts)
       current_time + 5.seconds
     end

     def max_attempts
       5
     end
end

