<template>
    <div>
        <h2>IP Information</h2>
        <table>
            <tbody>
                <tr>
                    <th>IP</th>
                    <td v-if="ip != null">{{ip.ip1}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>Int value</th>
                    <td v-if="ip != null">{{ip.ipI}}</td>
                    <td v-else></td>
                    <!--
                          <td>{{ip}}</td>
                -->


                </tr>
                <!-- Netblock -->
                <tr>
                    <th>NetBlock Name</th>
                    <td v-if="ip != null" @click="showNetBlock(ip.netBlockName)">{{ip.netBlockName}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                    <td v-else></td>
                </tr>

                <tr v-if="ip.hostInfo != null">
                    <th>in Host(s)</th>
                    <th>Id</th>
                    <th>Name</th>
                    <th>Host in App(s)</th>
                </tr>

                <tr v-else>
                    <th colspan="3">Not mapped to any Host</th>
                </tr>
                <tr v-for="(host, key) in ip.hostInfo" :key="key">
                    <td></td>
                    <td v-on:click="selectHost(host.idHostInfo)"><img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /> {{host.idHostInfo}}</td>
                    <td>{{host.name}}</td>
                    <td>
                        <ul v-for="(app, key) in host.appInfo" :key="key">
                            <li v-on:click="selectApp(app.idAppInfo)"><img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /> {{app.idAppInfo}} - {{app.appName}}</li>
                        </ul>
                    </td>
                </tr>

                <!-- Flow Categories -->
                <tr v-if="ip.categories != null && ip.categories.length != 0">
                    <th>Flow Category</th>
                    <th>Sub-Category</th>
                </tr>
                <tr v-else>
                    <th colspan="3">No Flow Categories</th>
                </tr>
                <tr v-for="(cat, key) in ip.categories" :key="key">
                    <td>{{cat[0]}}</td>
                    <!--
                                    <td>{{cat[1]}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                -->
                    <td v-on:click="selectFlowCat(cat[2], cat[0], cat[1], ip.ip1)">{{cat[1]}}<img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                </tr>

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
        name: 'DetailIP',
  data: function () {
    return {
      ip: null,
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
                  var apiUrl = '/api/ip/element?value=' + idHostInfo
      fetch(apiUrl)
        .then(response => response.json())
        .then(response => {
          if (response == null) {
            alert('API response is null ???')
          }
          this.ip = response
          return this.ip
        })

        }
    
          this.ip = null // this.createIp(idHostInfo)
        // alert (this.host.name)
        return this.ip 
    },
    createIp: function(nb) {
      this.debug += "createHost(" + nb + ")" + ";"
      var ip = JSON.parse('{"dateAdded":"2020-07-05T22:40:27.901832","lastSeen":"2020-07-05T22:40:27.901832","lastModified":"2020-07-05T22:40:27.901832","ip1":"192.168.0.1","ipI":3232235521,"ipVersion":4,"idHostInfo":null,"netBlockSource":"internal","netBlockName":"192.168.0.0/24","jsonData":null}'); 
      return ip
    },
    showNetBlock: function (netBlockName) {
        var keys = [ "netBlockName" ]
        var values = [ netBlockName ]
        // alert(netBlockName)
        this.$emit('toList', 'DetailIP','DetailNetblock','element', JSON.stringify(keys), JSON.stringify(values))
    },
    selectFlowCat: function (id,cat,subcat,ip) {
        var keys = ["id","cat","subcat","ip"]
        var values = [id, cat, subcat, ip]
        this.$emit('toList', 'DetailIP', 'ListFlow', 'element', JSON.stringify(keys), JSON.stringify(values))
      },
    selectHost: function (id) {
        var keys = ["id"]
        var values = [id]
        this.$emit('toList', 'DetailIP', 'DetailHost', 'element', JSON.stringify(keys), JSON.stringify(values))
      },
      selectApp: function (id) {
          var keys = ["id"]
          var values = [id]
          this.$emit('toList', 'DetailIP', 'DetailApp', 'element', JSON.stringify(keys), JSON.stringify(values))
      },
      notify: function (action) {
      this.debug += action + ";"
      // alert(action)ip
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
        if (newVal.component === "DetailIP") {
          var oval = JSON.parse(newVal.values); 
          if (oval.length == 0) {
            this.ip = this.fetchData()
          } else {
            this.ip = this.fetchData(oval[0])
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