<template>
    <div>
        <h2>List of Hosts</h2>
        <table>
            <thead>
                <tr>
                    <td> </td>
                    <th v-on:click="searchByValue('name', 'name')"> <img alt="sort" src="../assets/icons/1x/ic_search_black_18dp.png" /></th>
                    <td> </td>
                    <td> </td>
                    <td> </td>
                    <th v-on:click="searchByValue('hostSourceId', 'Source Id')"> <img alt="sort" src="../assets/icons/1x/ic_search_black_18dp.png" /></th>
                </tr>

                <tr>
                    <th v-if="this.orderBy == 'idHostInfo'">Id <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_black_18dp.png" /></th>
                    <th v-else v-on:click="setOrderBy('idHostInfo')">Id <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_white_18dp.png" /></th>
                    <th v-if="this.orderBy == 'name'">Name <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_black_18dp.png" /></th>
                    <th v-else v-on:click="setOrderBy('name')">Name <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_white_18dp.png" /></th>
                    <th>IPs</th>
                    <th>Name(s)</th>
                    <th>Source</th>
                    <th>Source Id </th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="host in items" :key="host.idHostInfo">
                    <td @click="showHost(host.idHostInfo)">{{host.idHostInfo}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                    <td>{{host.name}}</td>

                    <td style="text-align: left;">
                        <!-- {{app.appComponent.length}} -->
                        <span v-for="hip in host.hostInfoIp" :key="hip.ip">
                            <a v-on:click="selectIP(hip.ip)" v-if="host.hostInfoIp.length > 0" class="active">{{hip.ip}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></a>
                            <a v-else>No associated IP addresses</a>
                            <br />
                        </span>
                    </td>
                    <td style="text-align: left;">
                        <!-- {{app.appComponent.length}} -->
                        <span v-for="hin in host.hostInfoName" :key="hin.name">
                            <a v-if="host.hostInfoName.length > 0" class="active">{{hin.name}} </a>
                            <a v-else>No associated names</a>
                            <br />
                        </span>
                    </td>
                    <td>{{host.hostSource}}</td>
                    <td>{{host.hostSourceId}}</td>


                    <!--
                <td>{{app.jsonData}}</td>
                -->
                </tr>
            </tbody>
        </table>

        <p>
            <button @click="appsFirstPage">First</button>
            <button @click="appsPrevPage">Previous</button>
            <button @click="appsNextPage">Next</button>
            <button @click="appsLastPage">Last</button>
        </p>
        <p>
            {{currentPage}} of {{totalPages}}
        </p>
        <!--
        <h2>Message: {{msg}}</h2>
        <h3>Params: {{listParams}}</h3>
    -->
    </div>
</template>

<script>
export default {
  name: 'ListHost',
  data: function () {
    return {
      items: [],
      pageSize: 20,
      currentPage: 1,
      totalPages: 0,
        orderBy: "idHostInfo",
        searchBy: "list",
        searchValue: ""
    }
  },
  props: {
    msg: String,
    listParams: Object
  },
  created: function () {
    // alert("before");
    this.totalPages = 0
    this.items = this.fetchData()
  
  },

  methods: {
    fetchData: function (id) {
          if (document.location.host != "localhost:8080") {
              var apiUrl = '/api/host/list?PageNumber=' + (this.currentPage - 1)
                  + '&PageSize=' + this.pageSize
                  + '&OrderBy=' + this.orderBy
              if (this.searchBy != "list") {
                  apiUrl = '/api/host/search?PageNumber=' + (this.currentPage - 1)
                      + '&PageSize=' + this.pageSize
                      + '&SearchBy=' + this.searchBy
                      + '&SearchValue=' + this.searchValue
                      + '&SearchType=' + "contains"
              }
              // alert(apiUrl)
      fetch(apiUrl)
        .then(response => response.json())
        .then(response => {
          if (response == null) {
            alert('API response is null ???')
          }
          if (response.results == null) {
            alert('API response.result is null ??? [' + apiUrl + ']')
          }
          this.totalPages = response.totalNumberOfPages
          this.items = response.results
          return response.results
        })

        }
    
        if (id == null) {
            // return [this.createHost(1), this.createHost(2)]
        }
        // this.notify('fetchData(' + id + ')')
        return [] // [this.createHost(id)]
    },
    createHost: function(nb) {
      this.debug += "createHost(" + nb + ")" + ";"
      var host = {}
      host.idHostInfo = nb
      host.name= 'host' + nb
      host.hostInfoIp = []
      host.hostInfoIp[0] = {}
      host.hostInfoIp[0].ip = '192.168.0.' + nb
      host.hostInfoIp[0].netmask = '255.255.255.0'
      host.hostInfoIp[0].intf = 'eth0'
      return host
    },
    showHost: function (idHostInfo) {
        var keys = [ "idHostInfo" ]
        var values = [ idHostInfo ]
        this.$emit('toList', 'ListHost','DetailHost','element', JSON.stringify(keys), JSON.stringify(values))
    },
    selectIP: function (ip) {
        var keys = [ "ip" ]
        var values = [ ip ]
        this.$emit('toList','ListHost','DetailIP','element', JSON.stringify(keys), JSON.stringify(values))
        // {"dateAdded":"2020-07-05T22:40:27.901832","lastSeen":"2020-07-05T22:40:27.901832","lastModified":"2020-07-05T22:40:27.901832","ip1":"192.168.0.1","ipI":3232235521,"ipVersion":4,"idHostInfo":null,"netBlockSource":"internal","netBlockName":"192.168.0.0/24","jsonData":null}
      },
      setOrderBy: function (value) {
          // alert(value)
          this.orderBy = value;
      },
      searchByValue: function (value, desc) {
          var result = prompt('Search for ' + desc, '')
          if (result != null) {
              if (result != "") {
                  this.searchBy = value
                  this.searchValue = result
                  this.items = this.fetchData()
              } else {
                  this.searchBy = "list"
                  this.searchValue = ""
                  this.items = this.fetchData()
              }
          } else {
              this.searchBy = "list"
              this.searchValue = ""
              this.items = this.fetchData()
          }
      },
      appsFirstPage: function () {
          // alert('appsPrevPage()')
          if (this.currentPage > 1) {
              this.currentPage = 1
              this.fetchData()
          }
      },
      appsPrevPage: function () {
          // alert('appsPrevPage()')
          if (this.currentPage > 1) {
              this.currentPage--
              this.fetchData()
          }
      },
      appsNextPage: function () {
          // fetchData()
          if (this.currentPage < this.totalPages) {
              this.currentPage++
              // alert(this.currentPage)
              this.fetchData()
          }
      },
      appsLastPage: function () {
          // fetchData()
          if (this.currentPage < this.totalPages) {
              this.currentPage = this.totalPages
              // alert(this.currentPage)
              this.fetchData()
          }
      },

    showApp(idAppInfo) {
        // alert(idAppInfo);
        // TODO
        var keys = [ "idAppInfo" ]
        var values = [ idAppInfo ]
        // 
        this.$emit('toList','ListApps','DetailApp','element', JSON.stringify(keys), JSON.stringify(values))
    },
    notify: function(action) {
      alert(action)
    }

  },
  watch: {
    listParams: { 
    handler(newVal) { // val, oldVal
        // this.updateStatus(val, oldVal)
        // 
        // this.notify('here')
        // this.notify(newVal.action)
        // console.log('Prop changed: ', newVal, ' | was: ', oldVal)
        if (newVal.component === "ListHost") {
          if (newVal.keys.length == 0) {
            this.items = this.fetchData()
          } else {
            var oval = JSON.parse(newVal.values); 
            this.items = this.fetchData(oval[0])
          }
        }
     
        
      },
      deep: true 
      },
      orderBy: {
          handler() {
              this.items = this.fetchData()
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