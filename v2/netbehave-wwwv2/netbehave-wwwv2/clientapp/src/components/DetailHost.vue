<template>
    <div>
        <h2>Host Information</h2>
        <table>
            <tbody>
                <tr>
                    <th>Host id</th>
                    <td v-if="host != null">{{host.idHostInfo}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>Host name</th>
                    <td v-if="host != null">{{host.name}}</td>
                    <td v-else></td>
                    <!--
                          <td>{{host}}</td>
                -->
                </tr>

                <tr>
                    <th>Extra Data</th>
                </tr>

                <tr v-for="(value, key) in host.jsonData" :key="key">
                    <td>{{key}}</td>
                    <td>{{value}}</td>
                </tr>

                <tr v-if="host.appInfo != null">
                    <th>in App(s)</th>
                    <th>Id</th>
                    <th>Name</th>
                </tr>

                <tr v-else>
                    <th colspan="3">Not mapped to any App</th>
                </tr>

                <tr v-for="(app, key) in host.appInfo" :key="key">
                    <td></td>
                    <td v-on:click="selectApp(app.idAppInfo)"><img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /> {{app.idAppInfo}}</td>
                    <td>{{app.appName}}</td>
                </tr>

            </tbody>

        </table>


        <h3>List of IPs</h3>
        <table>
            <thead>
                <tr>
                    <th>IP</th>
                    <th>Netmask</th>
                    <th>Interface</th>
                </tr>
            </thead>
            <tbody v-if="host != null">
                <tr v-for="hip in host.hostInfoIp" :key="hip.ip">
                    <td v-on:click="selectIP(hip.ip)">{{hip.ip}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                    <td>{{hip.netmask}}</td>
                    <td>{{hip.intf}}</td>
                </tr>
            </tbody>
            <tbody v-else>
            </tbody>
        </table>

        <h3>List of Names</h3>
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                </tr>
            </thead>
            <tbody v-if="host != null">
                <tr v-for="hin in host.hostInfoName" :key="hin.name">
                    <td>{{hin.name}} </td>
                </tr>
            </tbody>
            <tbody v-else>
            </tbody>
        </table>

        <!--
            <h2>Message: {{msg}}</h2>
            <h3>Params: {{listParams}}</h3>
            <h3>Debug:[{{debug}}]</h3>
    -->
    </div>
</template>

<script>
export default {
  name: 'DetailHost',
  data: function () {
    return {
      host: null,
      params:this.listParams
    }
  },
  props: {
    msg: String,
    listParams: Object
  },
  created: function () {
    // alert("before");
    // this.host = null // this.fetchData()
  
  },

  methods: {
    fetchData: function (idHostInfo) {
      this.debug += "fetchData(" + idHostInfo + ")" + ";"
      if (idHostInfo == null) {
        return null;
      }
        if (document.location.host != "localhost:8080") {
                  var apiUrl = '/api/host/element?value=' + idHostInfo
      fetch(apiUrl)
        .then(response => response.json())
        .then(response => {
          if (response == null) {
            alert('API response is null ???')
          }
            this.host = response
            this.host.jsonData = JSON.parse(response.jsonData); 
          return this.host
        })

        }
    
          this.host = null // this.createHost(idHostInfo)
        // alert (this.host.name)
        return this.host 
    },
    createHost: function(nb) {
      this.debug += "createHost(" + nb + ")" + ";"
      var host = {}
      host.idHostInfo = nb
      host.name= 'host' + nb
      host.jsonData = { "extraInfo": "extraValue" + nb, "moreInfo": "Value" + nb }
      host.hostInfoIp = []
      host.hostInfoIp[0] = {}
      host.hostInfoIp[0].ip = '192.168.0.' + nb
      host.hostInfoIp[0].netmask = '255.255.255.0'
      host.hostInfoIp[0].intf = 'eth0'
      return host
    },
    selectIP: function (ip) {
        var keys = [ "ip" ]
        var values = [ ip ]
        this.$emit('toList', 'DetailHost','DetailIP','element', JSON.stringify(keys), JSON.stringify(values))
        // {"dateAdded":"2020-07-05T22:40:27.901832","lastSeen":"2020-07-05T22:40:27.901832","lastModified":"2020-07-05T22:40:27.901832","ip1":"192.168.0.1","ipI":3232235521,"ipVersion":4,"idHostInfo":null,"netBlockSource":"internal","netBlockName":"192.168.0.0/24","jsonData":null}
    },
    selectApp: function (id) {
        var keys = ["id"]
        var values = [id]
        this.$emit('toList', 'DetailHost', 'DetailApp', 'element', JSON.stringify(keys), JSON.stringify(values))
    },
    notify: function(action) {
      this.debug += action + ";"
      // alert(action)
    }

  },
  watch: {
    listParams: { 
    immediate: true,
    handler(newVal) { // val, oldVal
        // this.updateStatus(val, oldVal)
        // 
        this.debug += 'watch/listParams' + ";"
        // this.notify('watch/listParams' + JSON.stringify(oldVal))
        // this.notify(newVal.action)
        // console.log('Prop changed: ', newVal, ' | was: ', oldVal)
        if (newVal.component === "DetailHost") {
          var oval = JSON.parse(newVal.values); 
          if (oval.length == 0) {
            this.host = this.fetchData()
          } else if (oval.length == 1) {
            this.host = this.fetchData(oval[0])
          } else {
            this.host = this.fetchData(oval[2])
          }
        }
      },
      deep: true 
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a.active {
  color: #457b9d;
  text-decoration: none;
  display: inline-block;
}

</style>