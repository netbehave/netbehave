<template>
    <div>
        <h2>List of IPs</h2>
        <table>
            <thead>
                <tr>
                    <th v-on:click="searchByValue('ip1', 'IP')"> <img alt="sort" src="../assets/icons/1x/ic_search_black_18dp.png" /></th>
                    <td> </td>
                    <th v-on:click="searchByValue('netBlockName', 'NetBlock Name')"> <img alt="sort" src="../assets/icons/1x/ic_search_black_18dp.png" /></th>
                    <td> </td>
                    <td> </td>
                </tr>
                <tr>
                    <th v-if="this.orderBy == 'ip1'">IP <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_black_18dp.png" /></th>
                    <th v-else v-on:click="setOrderBy('ip1')">IP <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_white_18dp.png" /></th>

                    <th>Int value</th>
                    <th v-if="this.orderBy == 'netBlockName'">NetBlock Name <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_black_18dp.png" /></th>
                    <th v-else v-on:click="setOrderBy('netBlockName')">NetBlock Name <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_white_18dp.png" /></th>

                </tr>
            </thead>
            <tbody>
                <tr v-for="ip in items" :key="ip.ip1">
                    <td @click="selectIP(ip.ip1)">{{ip.ip1}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                    <td>{{ip.ipI}}</td>
                    <td @click="showNetBlock(ip.netBlockName)">{{ip.netBlockName}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
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
        orderBy: "ipI",
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
            var apiUrl = '/api/ip/list?PageNumber=' + (this.currentPage - 1)
                + '&PageSize=' + this.pageSize
                + '&OrderBy=' + this.orderBy
            if (this.searchBy != "list") {
                apiUrl = '/api/ip/search?PageNumber=' + (this.currentPage - 1)
                    + '&PageSize=' + this.pageSize
                    + '&SearchBy=' + this.searchBy
                    + '&SearchValue=' + this.searchValue
                    + '&SearchType=' + "contains"
            }
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
            // return [this.createIp(1), this.createIp(2)]
        }
        // this.notify('fetchData(' + id + ')')
        return [] // [this.createIp(id)]
    },
    createIp: function(nb) {
      this.debug += "createIp(" + nb + ")" + ";"
      var ip = JSON.parse('{"dateAdded":"2020-07-05T22:40:27.901832","lastSeen":"2020-07-05T22:40:27.901832","lastModified":"2020-07-05T22:40:27.901832","ip1":"192.168.0.1","ipI":3232235521,"ipVersion":4,"idHostInfo":null,"netBlockSource":"internal","netBlockName":"192.168.0.0/24","jsonData":null}'); 
      return ip
    },
    selectIP: function (ip) {
        var keys = [ "ip" ]
        var values = [ ip ]
        this.$emit('toList','ListIP','DetailIP','element', JSON.stringify(keys), JSON.stringify(values))
        // {"dateAdded":"2020-07-05T22:40:27.901832","lastSeen":"2020-07-05T22:40:27.901832","lastModified":"2020-07-05T22:40:27.901832","ip1":"192.168.0.1","ipI":3232235521,"ipVersion":4,"idHostInfo":null,"netBlockSource":"internal","netBlockName":"192.168.0.0/24","jsonData":null}
    },
    showNetBlock: function (netBlockName) {
        var keys = [ "netBlockName" ]
        var values = [ netBlockName ]
        this.$emit('toList','ListIP','DetailNetblock','element', JSON.stringify(keys), JSON.stringify(values))
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
        if (newVal.component === "ListIP") {
          if (newVal.keys.length == 0) {
            this.items = this.fetchData()
          } else {
            var oval = JSON.parse(newVal.values); 
            this.items = this.fetchData(oval[0])
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