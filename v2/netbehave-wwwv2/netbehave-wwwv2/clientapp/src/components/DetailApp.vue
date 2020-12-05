<template>
    <div>
        <h2>Application Information</h2>
        <table>
            <tbody>
                <tr>
                    <th>Id</th>
                    <td v-if="app != null">{{app.idAppInfo}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>Name</th>
                    <td v-if="app != null">{{app.appName}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>appSource</th>
                    <td v-if="app != null">{{app.appSource}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>appSourceId</th>
                    <td v-if="app != null">{{app.appSourceId}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>appDescription</th>
                    <td v-if="app != null">{{app.appDescription}}</td>
                    <td v-else></td>
                </tr>

                <tr>
                    <th>Extra Data</th>
                </tr>

                <tr v-for="(value, key) in app.jsonData" :key="key">
                    <td>{{key}}:</td>
                    <td>{{value}}</td>
<!--
                    <td></td>
                    <td>{{key}}:{{value}}</td>
-->
                </tr>
            </tbody>

        </table>


        <h3>List of Components</h3>
        <table>
            <thead>
                <tr>
                    <th>componentType</th>
                    <th>idHostInfo</th>
                </tr>
            </thead>
            <tbody v-if="app != null">
                <tr v-for="appco in app.appComponent" :key="appco.componentId">
                    <td>{{appco.componentType}}</td>
                    <td v-if="appco.appComponentHost.length > 0" v-on:click="selectHost(app.idAppInfo,appco.componentId,appco.appComponentHost[0].idHostInfo)">Host[{{appco.appComponentHost[0].idHostInfo }}] <i><img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></i></td>
                    <td v-else>No host found</td>
                    <td>{{appco.componentId}}</td>
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
  name: 'DetailApp',
  data: function () {
    return {
      app: null,
      params:this.listParams
    }
  },
  props: {
    msg: String,
    listParams: Object
  },
  created: function () {
    // alert("before");
    // this.app = null // this.fetchData()
  
  },

  methods: {
    changeObject() {
      this.debug += "changeObject()" + ";"
      this.$emit('toList','ListApps','return','["key1"]','["value1"]')
    },
    fetchData: function (idHostInfo) {
      this.debug += "fetchData(" + idHostInfo + ")" + ";"
      if (idHostInfo == null) {
        return null;
      }
        if (document.location.host != "localhost:8080") {
                  var apiUrl = '/api/app/element?value=' + idHostInfo
      fetch(apiUrl)
        .then(response => response.json())
        .then(response => {
          if (response == null) {
            alert('API response is null ???')
          }
          this.app = response
            this.app.jsonData = JSON.parse(response.jsonData); 
          return this.app
        })

        }
    
        this.app = null // this.createApp(idHostInfo)
        // alert (this.host.name)
        return this.app 
    },
    createApp: function(nb) {
      var app = {}
      app.idAppInfo = nb
      app.appName= 'app' + nb
      app.appSource = "src"
      app.appSourceId = "srcid"
      app.appDescription = "desc"
      app.jsonData = { "extraInfo": "extraValue" + nb }
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
        if (newVal.component === "DetailApp") {
          var oval = JSON.parse(newVal.values); 
          if (oval.length == 0) {
            this.app = this.fetchData()
          } else {
            this.app = this.fetchData(oval[0])
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