<!-- ListFlow -->
<template>
    <div>
        <h2 v-if="ip != null">List of Flow for IP {{ip}}</h2>
        <h2 v-else>List of Flow - no IP defined</h2>
        <table>
            <thead>
                <tr>
                    <th rowspan="2">Flow Category</th>
                    <th rowspan="2">Sub-Category</th>
                    <th colspan="2">Source</th>
                    <th colspan="2">Dest</th>
                </tr>
                <tr>
                    <th>IP</th>
                    <th>Host</th>
                    <th>IP</th>
                    <th>Host</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="(fs, key) in items" :key="key">
                    <td>{{fs.cat}}</td>
                    <td>{{fs.subcat}}</td>
                    <td>{{fs.srcip}}</td>


                    <td v-if="fs.srcIdHostInfo != null" v-on:click="selectHost(fs.srcIdHostInfo)"><img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /> {{fs.srcIdHostInfo}}</td>
                    <td v-else>No host</td>

                    <td>{{fs.dstip}}</td>
                    <td v-if="fs.dstIdHostInfo != null" v-on:click="selectHost(fs.dstIdHostInfo)"><img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /> {{fs.dstIdHostInfo}}</td>
                    <td v-else>No host</td>
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
        <h3>Debug:[{{debug}}]</h3>
    -->
    </div>
</template>
<script>export default {
  name: 'ListApps',
  data: function () {
      return {
      ip: "",
      items: [],
      pageSize: 20,
      currentPage: 1,
          totalPages: 0,
          orderBy: "ip",
          searchBy: "ip",
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
      if (this.listParams != null) {
          var oval = JSON.parse(this.listParams);
          this.ip = oval[3];
          // alert(this.ip)
      } else {
          alert("no listParams!")
      }
      this.items = this.fetchData(this.ip) // listParams["value"][3])

  },

  methods: {
    fetchData: function (ip) {
          if (document.location.host != "localhost:8080") {
            // var apiUrl = '/api/flowsummary/search?&SearchBy=ip&SearchValue=' + id + '&PageNumber=' + (this.currentPage - 1) + '&PageSize=' + this.pageSize
              // 

              var apiUrl = '/api/flowsummary/search?PageNumber=' + (this.currentPage - 1)
                  + '&PageSize=' + this.pageSize
                  + '&SearchBy=' + this.searchBy
                  + '&SearchValue=' + ip // this.searchValue
                  + '&SearchType=' + "equals"
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

        if (ip == null) {
            return [] // [this.createApp(1), this.createApp(2)]
        }
        // this.notify('fetchData(' + id + ')')
          return [] // [this.createApp(id)]
    },
      selectHost: function (idHostInfo) {
        // TODO
        var keys = [ "idHostInfo" ]
        var values = [ idHostInfo ]
        this.$emit('toList','ListFlow','HostInfo','element', JSON.stringify(keys), JSON.stringify(values))
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
        if (newVal.component === "ListFlow") {
          if (newVal.keys.length == 0) {
            this.items = this.fetchData("")
              // alert("???1")
          } else {
              var oval = JSON.parse(newVal.values);
              this.ip = oval[3];
              // alert(this.ip)
              this.items = this.fetchData(this.ip)
          }
        }


      },
      deep: true
    }
  }
}</script>

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