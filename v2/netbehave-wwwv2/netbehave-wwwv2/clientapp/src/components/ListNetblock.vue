<template>
    <div>
        <h2>List of Netblock</h2>
        <table>
            <thead>
                <tr>
                    <th v-on:click="searchByValue('netBlockName', 'name')"> <img alt="sort" src="../assets/icons/1x/ic_search_black_18dp.png" /></th>
                    <td> </td>
                    <th v-on:click="searchByValue('ip', 'IP address in Netblock')"> <img alt="sort" src="../assets/icons/1x/ic_search_black_18dp.png" /></th>
                    <td> </td>
                    <td> </td>
                </tr>
                <tr>
                    <th v-if="this.orderBy == 'netBlockName'">NetBlock Name <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_black_18dp.png" /></th>
                    <th v-else v-on:click="setOrderBy('netBlockName')">NetBlock Name <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_white_18dp.png" /></th>
                    <th>Subnet</th>
                    <th v-if="this.orderBy == 'ipStart'">IP Start<img alt="sort" src="../assets/icons/1x/ic_arrow_downward_black_18dp.png" /></th>
                    <th v-else v-on:click="setOrderBy('ipStart')">IP Start<img alt="sort" src="../assets/icons/1x/ic_arrow_downward_white_18dp.png" /></th>
                    <th>IP End</th>
                    <th>Block Size</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="netblock in items" :key="netblock.ipStart">
                    <td @click="showNetBlock(netblock.netBlockName)">{{netblock.netBlockName}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                    <td>{{netblock.netBlockSubnet}}</td>
                    <td>{{netblock.ipStart}}</td>
                    <td>{{netblock.ipEnd}}</td>
                    <td>{{netblock.netBlockSize}}</td>
                    <!--
    <td>{{netblock.jsonData}}</td>
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
  name: 'ListNetblock',
  data: function () {
    return {
      items: [],
      pageSize: 20,
      currentPage: 1,
        totalPages: 0,
        orderBy: "ipStart",
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
            var apiUrl = '/api/netblock/list?PageNumber=' + (this.currentPage - 1)
                + '&PageSize=' + this.pageSize
                + '&OrderBy=' + this.orderBy
            if (this.searchBy != "list") {
                apiUrl = '/api/netblock/search?PageNumber=' + (this.currentPage - 1)
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
            // return [this.createNetBlock(0), this.createNetBlock(1), this.createNetBlock(2)]
        }
        // this.notify('fetchData(' + id + ')')
        return [] // [this.createNetBlock(id)]
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
    showNetBlock: function (netBlockName) {
        var keys = [ "netBlockName" ]
        var values = [ netBlockName ]
        // alert(netBlockName)
        this.$emit('toList','ListNetblock','DetailNetblock','element', JSON.stringify(keys), JSON.stringify(values))
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
        if (newVal.component === "ListNetblock") {
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