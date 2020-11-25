<template>
    <div>


        <h2>List of Applications Components</h2>
        <table>
            <thead>
                <tr>
                    <th>Id App </th>
                    <th>Id Component</th>
                    <th>component Type</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="appco in items" :key="appco.componentId">
                    <td>{{appco.idAppInfo}}</td>
                    <td>{{appco.componentId}}</td>
                    <td>{{appco.componentType}}</td>
                </tr>
            </tbody>
        </table>
        <!--
    <h2>Message: {{msg}}</h2>
    <h3>Params: {{listParams}}</h3>
    -->

    </div>
</template>
<script>
export default {
  name: 'ListAppComponents',
  data: function () {
    return {
      items: [],
      pageSize: 20,
      appsCurrentPage: 1,
      appsTotalPages: 0
    }
  },
  props: {
    msg: String,
    listParams: Object
  },
  created: function () {
    // alert("before");
    this.appsTotalPages = 1
    this.items = this.fetchData()
  },

  methods: {
    fetchData: function (idAppInfo, componentId) {
        if (idAppInfo == undefined) {
            return [this.createAppCo(1,1), this.createAppCo(1,2)]
        }
        // 
        // this.notify('fetchData(' + idAppInfo + ')')
        return [this.createAppCo(idAppInfo, componentId)]
    },
    createAppCo: function(idAppInfo, componentId) {
      var appco = {}
      appco.componentId = componentId
      appco.componentType = 'server'
      appco.idAppInfo = idAppInfo
      return appco
    },
    notify: function(action) {
      alert(action)
    }

  },
  watch: {
    listParams: { 
    handler(newVal) { // newVal, oldVal
        if (newVal.component === "ListAppComponents") {
          // console.log('here')
          var oval = JSON.parse(this.listParams.values); 
          if (oval.length == 0) {
            // this.notify('empty')
            this.items = this.fetchData()
          } else {
            // this.notify(newVal.values.length)
            // console.log(newVal.values.length)
            // this.notify('in watch:' + oval[0] + ',' + oval[1])
            this.items = this.fetchData(oval[0], oval[1])
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
a {
  color: #42b983;
}
</style>