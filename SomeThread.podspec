Pod::Spec.new do |s|
  s.name         = "SomeThread"
  s.version      = "0.0.1"
  s.summary      = "An iOS task queue with guaranty to be working in one thread for each task"
  s.description  = <<-DESC
                    SomeThread is a class with similar to GCD serial queue idea. But it will do its task on the same thread. Also you could add timers, they will be executed on this thread as well. While idle thread is sleeping.
                   DESC
  s.homepage     = "https://github.com/smakeev/SomeThread"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Sergey Makeev' => 'Makeev.87@gmail.com' }
  s.source       = { :git => "https://github.com/smakeev/SomeThread.git", :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.source_files = '*.{h,m}'
  s.requires_arc = true
end
