<template>
    <div>
        <h2>Netblock Information</h2>
        <table>
            <tbody>
                <tr>
                    <th>Netblock Name</th>
                    <td v-if="netblock != null">{{netblock.netBlockName}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>Subnet</th>
                    <td v-if="netblock != null">{{netblock.netBlockSubnet}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>IP Start</th>
                    <td v-if="netblock != null">{{netblock.ipStart}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>IP End</th>
                    <td v-if="netblock != null">{{netblock.ipEnd}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>Block Size</th>
                    <td v-if="netblock != null">{{netblock.netBlockSize}}</td>
                    <td v-else></td>
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
            <tbody v-if="sublist != null">
                <tr v-for="ip in sublist" :key="ip.ip1">
                    <td @click="selectIP(ip.ip1)">{{ip.ip1}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                    <td>{{ip.ipI}}</td>
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
        name: 'DetailNetblock',
  data: function () {
    return {
      netblock: null,
      sublist: null,
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
    fetchSubData: function (netBlockName) {
      this.debug += "fetchData(" + netBlockName + ")" + ";"
      if (netBlockName == null) {
        return null;
      }
        if (document.location.host != "localhost:8080") {
                  var apiUrl = '/api/ip/search?SearchBy=netBlockName&SearchType=&SearchValue=' + netBlockName
      fetch(apiUrl)
        .then(response => response.json())
        .then(response => {
          if (response == null) {
            alert('API response is null ???')
          }
          if (response.results == null) {
            alert('API response.result is null ??? [' + apiUrl + ']')
          }
          this.sublist = response.results
          return this.sublist
        })

        }
    
        this.sublist = []
        // alert (this.host.name)
        return this.sublist 
    },
    fetchData: function (netBlockName) {
      this.debug += "fetchData(" + netBlockName + ")" + ";"
      if (netBlockName == null) {
        return null;
      }
        if (document.location.host != "localhost:8080") {
                  var apiUrl = '/api/netblock/element?value=' + netBlockName
      fetch(apiUrl)
        .then(response => response.json())
        .then(response => {
          if (response == null) {
            alert('API response is null ???')
          }
          this.netblock = response
          return this.netblock
        })

        }
    
        this.netblock = null // this.createNetBlock(0)
        // alert (this.host.name)
        return this.netblock 
    },
    createNetBlock: function(nbi) {
      this.debug += "createNetBlock(" + nbi + ")" + ";"
      var netblock = {}
      netblock.netBlockName = '192.168.' + nbi + '.0/24'
      netblock.ipStart= '192.168.' + nbi + '.1'
      netblock.ipEnd = '192.168.'+nbi+'.255'
      netblock.jsonData = { "extraInfo": "extraValue" + nbi, "moreInfo": "Value" + nbi }
      return netblock
    },
    selectIP: function (ip) {
        var keys = [ "ip" ]
        var values = [ ip ]
        this.$emit('toList', 'DetailNetblock','DetailIP','element', JSON.stringify(keys), JSON.stringify(values))
    },

    notify: function(action) {
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
        if (newVal.component === "DetailNetblock") {
          var oval = JSON.parse(newVal.values); 
          if (oval.length == 0) {
            this.netblock = this.fetchData()
          } else {
            this.netblock = this.fetchData(oval[0])
            this.sublist = this.fetchSubData(oval[0])

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