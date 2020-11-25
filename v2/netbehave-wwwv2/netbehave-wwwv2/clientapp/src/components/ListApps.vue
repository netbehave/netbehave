<template>
    <div>
        <h2>List of Applications</h2>
        <table>
            <thead>
                <tr>
                    <td> </td>
                    <th v-on:click="searchByValue('name', 'name')"> <img alt="sort" src="../assets/icons/1x/ic_search_black_18dp.png" /></th>
                    <td> </td>
                    <th v-on:click="searchByValue('appSourceId', 'Source Id')"> <img alt="sort" src="../assets/icons/1x/ic_search_black_18dp.png" /></th>
                    <td> </td>
                    <td> </td>
                </tr>

                <tr>
                    <th v-if="this.orderBy == 'idAppInfo'">Id <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_black_18dp.png" /></th>
                    <th v-else v-on:click="setOrderBy('idAppInfo')">Id <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_white_18dp.png" /></th>
                    <th v-if="this.orderBy == 'name'">Name <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_black_18dp.png" /></th>
                    <th v-else v-on:click="setOrderBy('name')">Name <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_white_18dp.png" /></th>
                    <th>Source</th>
                    <th v-if="this.orderBy == 'appSourceId'">Source Id <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_black_18dp.png" /></th>
                    <th v-else v-on:click="setOrderBy('appSourceId')">Source Id <img alt="sort" src="../assets/icons/1x/ic_arrow_downward_white_18dp.png" /></th>
                    <th>Description</th>
                    <th>Components</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="app in items" :key="app.idAppInfo">
                    <td @click="showApp(app.idAppInfo)">{{app.idAppInfo}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                    <td>{{app.appName}}</td>
                    <td>{{app.appSource}}</td>
                    <td>{{app.appSourceId}}</td>
                    <td>{{app.appDescription}}</td>
                    <td style="text-align: left;">
                        <!-- {{app.appComponent.length}} -->
                        <span v-for="appco in app.appComponent" :key="appco.componentId">
                            <a v-on:click="selectHost(app.idAppInfo,appco.componentId,appco.appComponentHost[0].idHostInfo)" v-if="appco.appComponentHost.length > 0" class="active">{{appco.componentType}} - Host[{{appco.appComponentHost[0].idHostInfo }}] - {{appco.componentId}} <!-- <i class="material-icons">info</i> --> <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></a>
                            <a v-else>{{appco.componentType}} - No host for {{appco.componentId}}</a>
                            <br />
                        </span>
                    </td>
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
  name: 'ListApps',
  data: function () {
    return {
      items: [],
      pageSize: 20,
      currentPage: 1,
        totalPages: 0,
        orderBy: "idAppInfo",
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
            var apiUrl = '/api/app/list?PageNumber=' + (this.currentPage - 1)
                + '&PageSize=' + this.pageSize
                + '&OrderBy=' + this.orderBy
            if (this.searchBy != "list") {
                apiUrl = '/api/app/search?PageNumber=' + (this.currentPage - 1)
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
            // return [this.createApp(1), this.createApp(2)]
        }
        // this.notify('fetchData(' + id + ')')
          return [] // [this.createApp(id)]
    },
    createApp: function(nb) {
      var app = {}
      app.idAppInfo = nb
      app.appName= 'app' + nb
      app.appSource = "src"
      app.appSourceId = "srcid"
      app.appDescription = "desc"
      app.jsonData = { "extraInfo": "extraValue" + nb, "moreInfo": "Value" + nb }
      app.appComponent = []
      app.appComponent[0] = {}
      app.appComponent[0].componentId = 1
      app.appComponent[0].componentType = 'www'
      app.appComponent[0].idAppInfo = app.idAppInfo
      app.appComponent[0].appComponentHost = []
      app.appComponent[1] = {}
      app.appComponent[1].componentId = 2
      app.appComponent[1].componentType = 'db'
      app.appComponent[1].idAppInfo = app.idAppInfo
      app.appComponent[1].appComponentHost = []
      app.appComponent[1].appComponentHost[0] = {}
      app.appComponent[1].appComponentHost[0].idHostInfo = 1
      return app
    },
    selectHost: function (idAppInfo, componentId, idHostInfo) {
        var keys = [ "idAppInfo", "componentId", "idHostInfo" ]
        var values = [ idAppInfo, componentId, idHostInfo ]
        this.$emit('toList','ListApps','DetailHost','element', JSON.stringify(keys), JSON.stringify(values))
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
        this.$emit('toList', 'ListApps','DetailApp','element', JSON.stringify(keys), JSON.stringify(values))
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
        if (newVal.component === "ListApps") {
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