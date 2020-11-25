<template>
    <div>
        <h2>List of Labels</h2>
        <!--
    -->

        <ul v-for="label in items" :key="label.idlabel">
            <li @click="showLabel(label.idlabel)">
                {{label.label1}} [{{label.desc}}]
                <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" />
                <ul v-for="child in label.children" :key="child.idlabel">
                    <li @click="showLabel(child.idlabel)">
                        {{child.label1}} [{{child.desc}}]
                        <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" />
                    </li>
                </ul>

            </li>
        </ul>

        <table>
            <thead>
                <tr>
                    <th>Id </th>
                    <th>Label</th>
                    <th>Description</th>
                    <th># Apps</th>
                    <th># Hosts</th>
                    <th># Flows</th>
                </tr>
            </thead>
            <tbody v-for="label in items" :key="label.idlabel">
                <tr>
                    <td @click="showLabel(label.idlabel)">{{label.idlabel}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                    <td>{{label.label1}}</td>
                    <td>{{label.desc}}</td>
                    <th v-if="label.counts['app_info'] != null">{{label.counts['app_info']}}</th>
                    <th v-else>0</th>
                    <th v-if="label.counts['host_info'] != null">{{label.counts['host_info']}}</th>
                    <th v-else>0</th>
                    <th v-if="label.counts['flow_summary'] != null">{{label.counts['flow_summary']}}</th>
                    <th v-else>0</th>

                </tr>
                <tr v-for="child in label.children" :key="child.idlabel">
                    <td @click="showLabel(child.idlabel)">{{child.idlabel}} <img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /></td>
                    <td>{{child.label1}}</td>
                    <td>{{child.desc}}</td>
                    <th v-if="child.counts['app_info'] != null">{{label.counts['app_info']}}</th>
                    <th v-else>0</th>
                    <th v-if="child.counts['host_info'] != null">{{label.counts['host_info']}}</th>
                    <th v-else>0</th>
                    <th v-if="child.counts['flow_summary'] != null">{{label.counts['flow_summary']}}</th>
                    <th v-else>0</th>
                </tr>
            </tbody>

        </table>
        <!--

    -->
        <!--
        <h2>Message: {{msg}}</h2>
        <h3>Params: {{listParams}}</h3>
    -->
    </div>
</template>
<script>
export default {
  name: 'ListLabels',
  data: function () {
    return {
      items: [],
      pageSize: 20,
      currentPage: 1,
        totalPages: 0,
        orderBy: "idlabel",
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
            var apiUrl = '/api/label/list?PageNumber=' + (this.currentPage - 1)
                + '&PageSize=' + this.pageSize
                + '&OrderBy=' + this.orderBy
            if (this.searchBy != "list") {
                apiUrl = '/api/label/search?PageNumber=' + (this.currentPage - 1)
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
      showLabel(idlabel) {
          // alert(idlabel);
          var keys = ["idlabel"]
          var values = [idlabel]
          this.$emit('toList', 'ListLabels', 'DetailLabel', 'element', JSON.stringify(keys), JSON.stringify(values))
        // TODO
        //
        /*
        //
        /* */
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

    oldul {
        list-style-type: none;
        padding: 0;
    }
    ul {
    }

    oldli {
        display: inline-block;
        margin: 0 10px;
    }
    li {
    }

    a.active {
        color: #457b9d;
        text-decoration: none;
        display: inline-block;
    }
</style>