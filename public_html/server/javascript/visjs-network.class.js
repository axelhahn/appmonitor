/**
 * 
 * HELPER CLASS to render network maps with VisJs
 * 
 * initial lines... I need to write some clean methods to remove 
 * hardcoded values 
 * 
 */
var visJsNetworkMap = function(){

    // ----------------------------------------------------------------------
    // SETTINGS
    // ----------------------------------------------------------------------

    // GRRR ... sorry for that
    this.name='oMap'; 
    this.sDomIdMap='mynetwork';
    this.sDomIdSelect='selView';
    // /GRRR

    this.container=document.getElementById(this.sDomIdMap);
    this.network;
    this.nodes = new vis.DataSet();
    this.edges = new vis.DataSet();
    
    this.bViewFullsize=false;
    this.sViewmode="UD";
    this.aViewmodes={
        "LR":{
            label: "left to right",
            levelSeparation: 200,
            nodeDistance: 100
        },
        "UD":{
            label: "up to down",
            levelSeparation: 150,
            nodeDistance: 175
        }
    };
    // this.visjsNetOptions = false;
    
    // ----------------------------------------------------------------------
    //
    // METHODS
    //
    // ----------------------------------------------------------------------


    // ----------------------------------------------------------------------
    // store and read variables
    // ----------------------------------------------------------------------

    this._getVarKey = function(sName){
        return location.pathname+'__visJsNetworkMap__'+sName;
    }

    this._saveVar = function(sName, value){
        return localStorage.setItem(this._getVarKey(sName), value );
    }
    this._getVar = function(sName){
        return localStorage.getItem(this._getVarKey(sName));
    }

    this._updateVisOptions = function (){
        this.visjsNetOptions = {
            layout: {
                hierarchical: {
                  direction: this.sViewmode,
                  sortMethod: "directed",
                  levelSeparation: this.aViewmodes[this.sViewmode]["levelSeparation"] 
                },
            },
            nodes: {
                shadow: { color: "#cccccc" }
            },
            physics: {
                hierarchicalRepulsion: {
                  nodeDistance: this.aViewmodes[this.sViewmode]["nodeDistance"]
                }
              },
            edges: {
                smooth: {
                  type: "cubicBezier",
                  forceDirection:
                    (this.sViewmode == "UD" || this.sViewmode == "DU")
                        ? "vertical"
                        : "horizontal",
                  roundness: 0.4,
                },
              }
        };
    }

    // ----------------------------------------------------------------------
    // network map
    // ----------------------------------------------------------------------

    /**
     * set objects of nodes and edges in the network
     * @param {object} nodesData 
     * @param {object} edgesData 
     */
    this.setData = function(nodesData, edgesData) {
        this.network = null;
        this.nodes.clear();
        this.edges.clear();
        this.nodes.add(nodesData);
        this.edges.add(edgesData);
    }

    /**
     * redraw visJs network map on div with id this.sDomIdMap
     * and update select
     */
    this.redrawMap = function() {
        this._updateVisOptions();
        this._saveVar("this.sViewmode", this.sViewmode);
        this._saveVar("this.bViewFullsize", this.bViewFullsize);
        
        this.container.className=( this.bViewFullsize===true || this.bViewFullsize==="true")  ? 'large':'';
        console.log(this.bViewFullsize);
        network = new vis.Network(
            this.container,
            { nodes: this.nodes, edges: this.edges }, 
            this.visjsNetOptions
        );
        this.renderSelectView();
    }
    
    // ----------------------------------------------------------------------
    // switch view and size
    // ----------------------------------------------------------------------

    this.renderSelectView = function() {
        var sHtml="<select onchange=\""+this.name+".switchViewMode(this.value);\">";
        for (s in this.aViewmodes){
            sHtml+="<option value=\""+s+"\"" + (s===this.sViewmode ? " selected=\"selected\"" : "" ) + ">"+this.aViewmodes[s]["label"]+"</option>"
        }
        sHtml+="</select>";
    
        var oSpan=document.getElementById(this.sDomIdSelect);
        oSpan.innerHTML=sHtml;
    }
    

    /**
     * switch direction of the tree
     * @param {string} sNewView  new direction; one of UD | LR 
     */
    this.switchViewMode = function (sNewView) {
        if(sNewView){
            this.sViewmode=sNewView;
        } else {
            this.sViewmode=(this.sViewmode==="LR" ? "UD" : "LR");
        }
        
        this.redrawMap();
    };

    /**
     * change size of the map by adding/ removing css class "large"
     */
    this.switchViewSize = function () {
        this.bViewFullsize=!!!this.bViewFullsize;
        this.redrawMap();
    }

    // ----------------------------------------------------------------------
    // MAIN
    // ----------------------------------------------------------------------

    /*
    if (arguments[0]) {
        this.setConfig(arguments[0]);
    }
    */

    this._updateVisOptions();
    this.bViewFullsize=this._getVar("this.bViewFullsize") ? this._getVar("this.bViewFullsize") : false;
    this.sViewmode=this._getVar("this.sViewmode") ? this._getVar("this.sViewmode") : "UD";
    return true;    
}