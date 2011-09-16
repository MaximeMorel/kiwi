module kiwi.core.port;

import kiwi.core.data;
import kiwi.core.base;
import kiwi.core.commons;

alias int DataAccessFlag;

enum{ READ = 1, WRITE=2, READ_WRITE = READ | WRITE
    , DATA=4, SIGNAL=8, SEMANTIC=16};

class OutputPort
{
    this(string name, Node n, DataStrategy dataStrategy = null)
    {
        _node = n;
        _parent = null;
        _name = name;
        _setDataStrategy(dataStrategy); 
    }

    this(string name, Node n, OutputPort parent, DataStrategy dataStrategy)
    {
        _node = n;
        _parent = parent;
        _name = name;
        _setDataStrategy(dataStrategy);
    }
    
    @property
    {
        Node node()
        {
            return _node;
        }

        bool hasDataStrategy()
        {
            return _dataStrategy !is null;
        }
        
        bool isComposite() // TODO
        {
            return false;
        }

        bool isSubPort()
        {
            return _parent !is null;
        }

        DataTypeInfo dataType()
        {
            if ( this.hasDataStrategy() ) return _dataStrategy.dataType;
            else return null;
        }

        Data data()
        {
            if ( hasDataStrategy ) return _dataStrategy.data;
            else return null;
        }

        DataAccessFlag accessFlags()
        {
            if ( hasDataStrategy ) return _dataStrategy.accessFlags;
            else return 0;
        }

        string name()
        {
            return _name;
        }

        OutputPortModifier modify()
        {
            return _modifier;
        }

        bool isAlterable()
        {
            return _modifier !is null;
        }

        InputPort[] connections()
        {
            return _connections;
        }

        void disconnectAll()
        {
            for(int i = 0; i < _connections.length; ++i)
                this.disconnect(_connections[i]);
        }
        
    } // properties

    
    bool isCompatible( InputPort port )
    {
        return port.isCompatible(this);
    }

    bool isConnectedTo( InputPort port )
    {
        foreach( p ; _connections)
        {
            if( p is port) return true;
        }
        return false;
    }   

    bool connect(InputPort port)
    {
        if ( port is null )
            return false;
        return port.connect(this);
    }

    bool disconnect( InputPort port )
    {
        if(port is null)
                return false;
            
        return port.disconnect(this);
    }

    final bool opBinary(string op)(InputPort port) if (op == ">>")
    {
        return connect( port );
    }

    
protected:
    /++
     + Returns the index of an output port in connections, or -1 if not found.
     +/ 
    protected int indexOf(InputPort port)
    {
        for(int i = 0; i < connections.length; ++i){
            if( connections[i] is port )
                return i;
        }
        return -1;
    }

    void _setDataStrategy(DataStrategy component)
    {
        mixin( logFunction!"OutputPort._setDataStrategy" );
        if ( component is _dataStrategy ) return;

        _dataStrategy = component;
    }
private:

    Node    _node;
    string  _name;
    InputPort[] _connections;
    OutputPortModifier _modifier;
    OutputPort _parent;
    
    // components
package DataStrategy _dataStrategy;
    //PortInfoStrategy   _portInfoStrategy;
    
}




class InputPort
{
    this(string portName, Node n, CompatibilityStrategy comp)
    {
        _name = portName;
        _node = n;
        _compatibilityStrategy = comp;
    }
    
    @property
    {

        Node node()
        {
            return _node;
        }

        Data data()
        {
            if (isConnected) return _connection.data;
            return null; 
        }
            
        DataAccessFlag accessFlags()
        {
            return _accessFlags;
        }

        OutputPort connection()
        {
            return _connection;
        }

        bool isConnected()
        {
            return _connection !is null;
        }
        
        bool hasCompatibilityStrategy()
        {
            return _compatibilityStrategy !is null;
        }

    }

    bool isCompatible( OutputPort port )
    {
        mixin( logFunction!"InputPort.isCompatible" );
        if ( !( accessFlags & port.accessFlags) && accessFlags != port.accessFlags )
        {
            log.writeDebug(0,"incompatible flags ", accessFlags, " ", port.accessFlags, "\n" );
            return false;
        }
        if ( hasCompatibilityStrategy )
            return _compatibilityStrategy.isCompatible(this, port);
        return true;
    }

    bool isConnectedTo( OutputPort port )
    {
        return _connection is port;
    }

    bool connect(OutputPort port)
    {
        mixin( logFunction!"InputPort.connect" );
        
        if (port is null)
            return false;

        if (! isCompatible(port) )
            return false;

        if( this.isConnected ) disconnect();
        
        this._connection = port;
        port._connections ~= this;
        log.writeDebug(0,"connected\n");
        return true;       
    }

    /++
     + Disconnect this port from an OutputPort if they are conected.
     +/ 
    bool disconnect( OutputPort port = null)
    out
    {
        if(port !is null) assert( !port.isConnectedTo(this), "disconnection failed." ); 
        assert( !this.isConnectedTo(port), "disconnection failed." ); 
    }
    body
    {
        mixin( logFunction!"InputPort.disconnect" );

        if ( port !is null && _connection !is port ) return false;
        else
        {
            if ( _connection is null ) return false;
            port = this._connection;
        }
        
        int i2 = port.indexOf(this);
        
        // proceed with the disconnection
        this._connection = null;
        port._connections[i2] = port._connections[$-1];
        port._connections.length -= 1;
        return true;
    }
    
private:
    Node _node;
    DataAccessFlag _accessFlags;
    string _name;
    OutputPort _connection;
    InputPortModifier _modifier;
    // components
    CompatibilityStrategy  _compatibilityStrategy;
    //PortInfoStrategy       _portInfoStrategy;
}




// -----------------------------------------------------------------------------

interface CompatibilityStrategy
{
    bool isCompatible(InputPort self, OutputPort port);
    final string StrategyType() { return "CompatibilityStrategy"; }
}


class DataTypeCompatibility : CompatibilityStrategy
{
	this(DataTypeInfo[] compatibleTypes)
	{
		_compatibleTypes = compatibleTypes;
	}
	
	this(DataTypeInfo compatibleType)
	{
		_compatibleTypes ~= compatibleType;
	}

	override bool isCompatible(InputPort self, OutputPort port)
	in
	{
		assert ( port !is null);
	}
	body
	{	
		foreach ( typeInfo ; _compatibleTypes )
		{
			if (port.dataType is typeInfo)
				return true;
		}
		return false;
	}

private:
	DataTypeInfo[] _compatibleTypes;
}


/**
 * Runtime compatibility policy for kiwi.dynamic.InputPort objects, always compatible.
 */
class AlwaysCompatible : CompatibilityStrategy
{
	override bool isCompatible(InputPort self, OutputPort port)
	in
	{
		assert ( port !is null);
	}
	body
	{
        mixin( logFunction!"AlwaysCompatible.isCompatible" );
		return true;
	}
}

/**
 * Runtime compatibility policy for kiwi.dynamic.InputPort objects, never compatible.
 */
class NeverCompatible : CompatibilityStrategy
{
	override bool isCompatible(InputPort self, OutputPort port)
	in
	{
		assert ( port !is null);
	}
	body
	{
		return false;
	}
}


// ---------------------------


interface DataStrategy
{
    enum{ USER = 0, ENGINE = 1 };
    @property
    {
        Data data();
        DataTypeInfo dataType();
        DataAccessFlag accessFlags();
        int componentFlags();
        final string StrategyType() { return "DataStrategy"; }
    }
        
}



class InputPortModifier
{
    this(InputPort port)
    {
        _port = port;
    }
    
    bool rename(string newName)
    {
        if(_port._modifier !is this) return false;
        _port._name = newName;
        return true;
    }
    
    private InputPort _port;
}

class OutputPortModifier
{
    this(OutputPort port)
    {
        _port = port;
    }
    
    bool rename(string newName)
    {
        if(_port._modifier !is this) return false;
        _port._name = newName;
        return true;
    }
    private OutputPort _port;
}



//            #####   #####    ####   #####    ####
//              #     #       #         #     #
//              #     ###      ###      #      ###
//              #     #           #     #         #
//              #     #####   ####      #     ####



version(unittest)
{
    import kiwi.dynamic.compatibility;
    import kiwi.core.datastrategy;

    Data NewContainerTest()
    {
        return new ContainerTest();
    }

    class SubContainerTest : kiwi.core.base.Data
    {
        static this()
        {
            mixin( logFunction!"SubContainerTest.static_constructor" );
            _typeInfo = DataTypeManager.Register!SubContainerTest;
            assert( _typeInfo !is null );
            assert( DataTypeManager["SubContainerTest"] !is null);
            assert( DataTypeManager["SubContainerTest"] is _typeInfo );
        }
       
        override DataTypeInfo type(){ return _typeInfo; }
        static DataTypeInfo Type(){ return _typeInfo; }
        override @property Data[] subData(){ return []; }
        private static DataTypeInfo _typeInfo;
       
    } 

    class ContainerTest : kiwi.core.base.Data
    {
        mixin DeclareSubDataTypes!(SubContainerTest,SubContainerTest);

        
        invariant()
        {
            assert( _subData.length == 2 );   
        }

        this()
        {
            _subData ~= new SubContainerTest();
            _subData ~= new SubContainerTest();
        }

        static this()
        {
            mixin( logFunction!"ContainerTest.static_constructor" );
            _typeInfo = DataTypeManager.Register!ContainerTest;
            assert( _typeInfo !is null );
            assert( DataTypeManager["ContainerTest"] !is null);
            assert( DataTypeManager["ContainerTest"] is _typeInfo );
            assert( _typeInfo.name == "ContainerTest");
            assert( _typeInfo.subData.length == 2);
        }

        //override bool serialize( DataStream stream ){ return false; }
        //override bool deSerialize( const DataStream stream ){ return false; }
        override DataTypeInfo type(){ return _typeInfo; }
        static DataTypeInfo Type(){ return _typeInfo; }
        override @property Data[] subData(){ return _subData; }
        
    private Data[] _subData;
    private static DataTypeInfo _typeInfo; 
    }
}



unittest
{
    mixin(logTest!"kiwi.core.port");
    
    log.writeln( "ContainerTest.Type.name: ", ContainerTest.Type.name );
    assert( ContainerTest.Type.subData.length == 2 );
    assert( ContainerTest.Type.subData[0].name == "SubContainerTest" );

    auto op_1 = new OutputPort( "op_1", null, new UserAllocatedDataStrategy( new ContainerTest, READ ) );
    auto ip_1 = new InputPort(  "ip_1", null, new AlwaysCompatible );

    auto op_2 = new OutputPort( "op_1", null, new UserAllocatedDataStrategy( new ContainerTest, READ ) );
    auto ip_2 = new InputPort(  "ip_2", null, new AlwaysCompatible );

    // simply trying every connection/disconnection cases.

    assert( !(op_1 is null) && !(ip_1 is null) );
    assert( !op_1.isConnectedTo(ip_1) );
    assert( !ip_1.isConnectedTo(op_1) );
    //assert( op_1.isComposite() ); // TODO
    assert( op_1.connect(ip_1) );
    assert( ip_1.isConnectedTo(op_1) );
    assert( op_1.isConnectedTo(ip_1) );

    assert( op_1.disconnect(ip_1) );
    assert( !op_1.disconnect(ip_1) ); // should fail and return false without crash
    assert( !ip_1.disconnect(op_1) ); // should fail and return false without crash

    assert( !op_1.isConnectedTo(ip_1) );
    assert( !ip_1.isConnectedTo(op_1) );

    assert( ip_1.connect(op_1) );
    assert( op_1.isConnectedTo(ip_1) );
    assert( ip_1.isConnectedTo(op_1) );

    assert( ip_1.disconnect(op_1) );
    assert( !op_1.isConnectedTo(ip_1) );
    assert( !ip_1.isConnectedTo(op_1) );

    // multiple connections
    assert( op_1.connect(ip_1) );
    assert( op_2.connect(ip_1) );

    assert( op_2.isConnectedTo(ip_1) );
    assert( !op_1.isConnectedTo(ip_1) );

    assert( op_2.disconnect(ip_1) );

    assert( !op_2.isConnectedTo(ip_1) );
    assert( !op_1.isConnectedTo(ip_1) );

    assert( ip_1.connect(op_2) );

    assert( op_2.isConnectedTo(ip_1) );
    assert( !op_1.isConnectedTo(ip_1) );
}


