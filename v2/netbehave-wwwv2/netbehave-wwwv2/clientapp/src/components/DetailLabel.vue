<template>
    <div>
        <h2>Label Information</h2>
        <table>
            <tbody>
                <tr>
                    <th>Id</th>
                    <td v-if="label != null">{{label.idlabel}}</td>
                    <td v-else></td>
                </tr>
                <tr>
                    <th>Name</th>
                    <td v-if="label != null">{{label.label1}}</td>
                    <td v-else></td>
                </tr>
            </tbody>

        </table>

        <h3>List of Apps</h3>
        <table>
            <tr>
                <th>Id</th>
                <th>Name(s)</th>
                <th>Source</th>
                <th>Source Id </th>
                <th>Description</th>
            </tr>


            <tr v-for="(app, key) in label.apps" :key="key">
                <td></td>
                <td v-on:click="selectApp(app.idAppInfo)"><img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /> {{app.idAppInfo}}</td>
                <td>{{app.appName}}</td>
                <td>{{app.appSource}}</td>
                <td>{{app.appSourceId}}</td>
                <td>{{app.appDescription}}</td>
            </tr>
        </table>

        <h3>List of Hosts</h3>
        <table>
            <tr>
                <th>Id</th>
                <th>Name(s)</th>
                <th>Source</th>
                <th>Source Id </th>
            </tr>

            <tr v-for="(host, key) in label.hosts" :key="key">
                <td></td>
                <td v-on:click="selectHost(host.idHostInfo)"><img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /> {{host.idHostInfo}}</td>
                <td>{{host.name}}</td>
                <td>{{host.hostSource}}</td>
                <td>{{host.hostSourceId}}</td>
                <td>
                    <ul v-for="(app, key) in host.appInfo" :key="key">
                        <li v-on:click="selectApp(app.idAppInfo)"><img alt="info" src="../assets/icons/1x/baseline_info_black_18dp.png" /> {{app.idAppInfo}} - {{app.appName}}</li>
                    </ul>
                </td>
            </tr>
        </table>
        <h3>List of Flows</h3>
<!--
            <h2>Message: {{msg}}</h2>
            <h3>Params: {{listParams}}</h3>
            <h3>Debug:[{{debug}}]</h3>
-->
    </div>
</template>

<script>
    export default {
        name: 'DetailLabel',
        data: function () {
            return {
                label: null,
                params: this.listParams
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
            fetchData: function (id) {
                this.debug += "fetchData(" + id + ")" + ";"
                if (id == null) {
                    return null;
                }
                if (document.location.host != "localhost:8080") {
                    var apiUrl = '/api/label/element?value=' + id
                    fetch(apiUrl)
                        .then(response => response.json())
                        .then(response => {
                            if (response == null) {
                                alert('API response is null ???')
                            }
                            this.label = response
                            return this.label
                        })

                }

                this.label = null // this.createIp(idHostInfo)
                // alert (this.host.name)
                return this.label
            },

            notify: function (action) {
                this.debug += action + ";"
                // alert(action)ip
            },
            selectHost: function (id) {
                var keys = ["id"]
                var values = [id]
                this.$emit('toList', 'DetailLabel', 'DetailHost', 'element', JSON.stringify(keys), JSON.stringify(values))
            },
            selectApp: function (id) {
                var keys = ["id"]
                var values = [id]
                this.$emit('toList', 'DetailLabel', 'DetailApp', 'element', JSON.stringify(keys), JSON.stringify(values))
            },

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
                    if (newVal.component === "DetailLabel") {
                        var oval = JSON.parse(newVal.values);
                        if (oval.length == 0) {
                            this.ip = this.fetchData()
                        } else {
                            this.ip = this.fetchData(oval[0])
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