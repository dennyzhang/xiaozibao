include "ecae.thrift"

service Ecae_mgmtService extends ecae.EcaeService {
map<string,string> getPhpEnv(1:string siteid)

}
