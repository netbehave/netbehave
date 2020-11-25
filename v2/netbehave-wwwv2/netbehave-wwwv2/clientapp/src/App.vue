<template>
   <div id="app">
   
       <button v-for="tab in tabs" :key="tab" @click="selectedTab = tab; selectTab(tab)" :class="['tab-btn', { active: selectedTab === tab }]">
      {{ tab }}
    </button>

   <!--
    <h2>fromChild: {{fromChild}}</h2>
    <h2>selected: {{selectedTab}}</h2>
    <h2>component: {{component}}</h2>
    -->
    <keep-alive>
      <component v-bind:is="component" :msg="msg" :listParams="listParams" @messageFromChild="childMessageReceived" @toList="fromList" class="tab" style="width: 50%; margin-left: 200px;" />
    </keep-alive>
  
   </div>
</template>

<script>
import ListApps from './components/ListApps.vue'
import ListHost from './components/ListHost.vue'
import ListIP from './components/ListIP.vue'
import ListNetblock from './components/ListNetblock.vue'
import ListFlow from './components/ListFlow.vue'
import ListLabels from './components/ListLabels.vue'

import DetailHost from './components/DetailHost.vue'
import DetailApp from './components/DetailApp.vue'
import DetailIP from './components/DetailIP.vue'
import DetailNetblock from './components/DetailNetblock.vue'
import DetailLabel from './components/DetailLabel.vue'
// import Test2 from './components/Test2.vue'
// import ListAppComponents from './components/ListAppComponents.vue'

export default {
  name: 'app',
  components: {
      ListApps, ListHost, ListIP, ListNetblock, ListFlow, ListLabels,
      DetailApp, DetailHost, DetailIP, DetailNetblock, DetailLabel
      // Test2, , , ListAppComponents
  },
  data (){
    return {
        tabs: ["Apps", "Hosts", "IPs", "Net Blocks", "Flows", "Labels", "Unknown"],
      selectedTab: "Apps",
      component:"ListApps",
      msg:"From Parent",
      fromChild:"",
      counter:0,
      listParams: {
        component: "",
        action: "nop",
        keys: [],
        values: []
      },
      idHostInfo:""
    }
  },
  methods: {
    selectTab(tabName) {
        switch(tabName) {
            case "Apps":
                this.component = ListApps;
                break;
            case "Hosts":
                this.component = ListHost;
                break;
            case "IPs":
                this.component = ListIP;
                break;
            case "Net Blocks":
                this.component = ListNetblock;
                break;
            case "Flows":
                this.component = ListFlow;
                break;
            case "Labels":
                this.component = ListLabels;
                break;
        }
    },
    childMessageReceived(arg1, arg2) {
      this.fromChild = arg1 + ',' + arg2
    },
    fromList(fromComponent,toComponent,action,keys,values) {
      this.fromChild = fromComponent + '=>' + toComponent + ':' + action + ',' + keys+ '=' + values
      this.msg = 'from ' + fromComponent
      this.listParams.action = action
      this.listParams.keys = keys
      this.listParams.values = values
      /*
      if (fromComponent == "Test2") {
        this.listParams.component = "ListApps"
        this.component = ListApps;
        this.selectedTab = "Apps";
      }
      if (fromComponent === "ListApps") {
        else {
            this.msg += " humm " 
            this.listParams.component = "Test2"
            // this.component = Test2;
            // this.selectedTab = "IPs";
        }
      }
      if (fromComponent == "ListNetblock") {
        this.listParams.component = "ListNetblock"
        this.component = ListNetblock;
        this.selectedTab = "Net Blocks";
      }
      */
        // alert(toComponent)
        if (toComponent === "DetailHost") {
           // this.component = DetailHost;
           this.listParams.component = "DetailHost"
            var oval = JSON.parse(values); 
            this.msg += " DetailHost = " + oval[2]
            // this.idHostInfo = "" + oval[2]
           this.selectedTab = "DetailHost";
           this.component = DetailHost;
        } 
 
        if (toComponent === "DetailIP") {
            this.listParams.component = "DetailIP"
            oval = JSON.parse(values); 
            this.msg += " DetailIP = " + oval[0]
            // this.idHostInfo = "" + oval[2]
            this.selectedTab = "DetailIP";
            this.component = DetailIP;
        } 

        if (toComponent === "DetailApp") {
            this.listParams.component = "DetailApp"
            oval = JSON.parse(values); 
            this.msg += " DetailApp = " + oval[0]
            // this.idHostInfo = "" + oval[2]
            this.selectedTab = "DetailApp";
            this.component = DetailApp;
        } 
      
        if (toComponent === "DetailHost") {
            this.listParams.component = "DetailHost"
            oval = JSON.parse(values); 
            this.msg += " DetailHost = " + oval[0]
            // this.idHostInfo = "" + oval[2]
            this.selectedTab = "DetailHost";
            this.component = DetailHost;
        } 
        
        if (toComponent === "DetailNetblock") {
            this.listParams.component = "DetailNetblock"
            oval = JSON.parse(values); 
            this.msg += " DetailNetblock = " + oval[0]
            // this.idHostInfo = "" + oval[2]
            this.selectedTab = "DetailNetblock";
            this.component = DetailNetblock;
        } 

        if (toComponent === "DetailLabel") {
            this.listParams.component = "DetailLabel"
            oval = JSON.parse(values);
            this.msg += " DetailLabel = " + oval[0]
            // this.idHostInfo = "" + oval[2]
            this.selectedTab = "DetailLabel";
            this.component = DetailLabel;
        } 

        if (toComponent === "ListFlow") {
            this.listParams.component = "ListFlow"
            oval = JSON.parse(values);
            // this.msg += " Netblock = " + oval[0]
            // this.idHostInfo = "" + oval[2]
            // this.selectedTab = "Netblock";
            this.component = ListFlow;
        } 

      
    }
  }
}
</script>
<link href="https://fonts.googleapis.com/icon?family=Material+Icons"
      rel="stylesheet">
<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

.tab-btn {
  padding: 6px 10px;
  background: #ffffff;
  cursor: pointer;
  margin-bottom: 1rem;
  border: 2px solid #cccccc;
  outline: none;
}

.active {
  border-bottom: 3px solid green;
  background: #fcfcf;
}

.tab {
  border: 1px solid #ccc;
  padding: 10px;
}

@font-face {
  font-family: 'Material Icons';
  font-style: normal;
  font-weight: 400;
  src: url(/assets/iconfont/MaterialIcons-Regular.eot); /* For IE6-8 */
  src: local('Material Icons'),
    local('MaterialIcons-Regular'),
    url(/assets/iconfont/MaterialIcons-Regular.woff2) format('woff2'),
    url(/assets/iconfont/MaterialIcons-Regular.woff) format('woff'),
    url(/assets/iconfont/MaterialIcons-Regular.ttf) format('truetype');
}

.material-icons {
  font-family: 'Material Icons';
  font-weight: normal;
  font-style: normal;
  font-size: 24px;  /* Preferred icon size */
  display: inline-block;
  line-height: 1;
  text-transform: none;
  letter-spacing: normal;
  word-wrap: normal;
  white-space: nowrap;
  direction: ltr;

  /* Support for all WebKit browsers. */
  -webkit-font-smoothing: antialiased;
  /* Support for Safari and Chrome. */
  text-rendering: optimizeLegibility;

  /* Support for Firefox. */
  -moz-osx-font-smoothing: grayscale;

  /* Support for IE. */
  font-feature-settings: 'liga';
}
</style>
