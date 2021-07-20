# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Reference: https://konghq.com/install/#kong-community
include_recipe 'postgresql'
include_recipe 'git'

apt_update do
  action :update
end

package 'install packages' do
  package_name node['kong']['packages']
  action :install
end

# Clone Kong source code per license requirements.
git '/usr/src/kong' do
  repository 'https://github.com/kong/kong.git'
  reference node['kong']['version']
  action :checkout
end

# Download md5 checksum from apache
remote_file '/tmp/kong.deb' do
  source "https://download.konghq.com/gateway-2.x-debian-stretch/pool/all/k/kong/kong_#{node['kong']['version']}_amd64.deb"
  verify "echo '#{node['kong']['sha1']} %{path}' | sha1sum -c"
  action :create
end

bash 'Install Kong Binary' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    # Install deb package
    dpkg -i kong.deb
EOH
end
