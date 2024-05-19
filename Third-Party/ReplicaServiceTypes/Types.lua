-- External Types for ReplicaService
export type ReplicaService = {
	ActivePlayers: { [Player]: boolean? },
	NewActivePlayerSignal: ScriptSignal<Player>,
	RemovedActivePlayerSignal: ScriptSignal<Player>,

	Temporary: ServiceReplica<any>,

	PlayerRequestedData: ScriptSignal<Player>,

	NewClassToken: (class_name: string) -> ReplicaClassToken,
	NewReplica: (replica_params: ReplicaParams) -> ServiceReplica<any>,
	CheckWriteLib: (module_script: ModuleScript?) -> (),
}

export type ReplicaController = {
	NewReplicaSignal: ScriptSignal<ControllerReplica<any>>,
	InitialDataReceivedSignal: ScriptSignal<>,
	InitialDataReceived: boolean,

	RequestData: () -> (),
	ReplicaOfClassCreated: (replica_class: string, listener: (replica: ControllerReplica<any>) -> ()) -> (),
	GetReplicaById: (replica_id: number) -> ControllerReplica<any>?,
}

export type Replica<Data = any> = {
	Data: Data,

	Id: number,
	Class: string,
	Tags: { [any]: any },

	Parent: Replica<Data>?,
	Children: { Replica<Data> },

	Identify: (self: Replica<Data>) -> string,

	IsActive: (self: Replica<Data>) -> boolean,

	AddCleanupTask: (self: Replica<Data>, task: any) -> (),
	RemoveCleanupTask: (self: Replica<Data>, task: any) -> (),
}

-- Service (Server)
export type ServiceReplica<Data = any> = Replica<Data> & {
	SetValue: (self: ServiceReplica<Data>, path: { string } | string, value: any) -> (),
	SetValues: (self: ServiceReplica<Data>, path: { string } | string, values: { [any]: any }) -> (),

	ArrayInsert: (self: ServiceReplica<Data>, path: { string } | string, value: any) -> { any },
	ArraySet: (self: ServiceReplica<Data>, path: { string } | string, index: any, value: any) -> (),
	ArrayRemove: (self: ServiceReplica<Data>, path: { string } | string, index: any) -> (),

	Write: (self: ServiceReplica<Data>, function_name: string, ...any) -> any,

	ConnectOnServerEvent: (self: ServiceReplica<Data>, listener: (player: Player, ...any) -> ()) -> ScriptConnection,
	FireClient: (self: ServiceReplica<Data>, player: Player, ...any) -> (),
	FireAllClients: (self: ServiceReplica<Data>, ...any) -> (),

	SetParent: (self: ServiceReplica<Data>, replica: ServiceReplica<Data>) -> (),

	ReplicateFor: (self: ServiceReplica<Data>, player: "All" | Player) -> (),
	DestroyFor: (self: ServiceReplica<Data>, player: "All" | Player) -> (),

	Destroy: (self: ServiceReplica<Data>) -> (),

	-- Listeners (Experimental)
	ListenToChange: (
		self: ServiceReplica<Data>,
		path: { string } | string,
		listener: (new_value: any, old_value: any) -> ()
	) -> ScriptConnection,
	ListenToNewKey: (
		self: ServiceReplica<Data>,
		path: { string } | string,
		listener: (new_value: any, new_key: any) -> ()
	) -> ScriptConnection,

	ListenToArrayInsert: (
		self: ServiceReplica<Data>,
		path: { string } | string,
		listener: (new_index: any, new_value: any) -> ()
	) -> ScriptConnection,
	ListenToArraySet: (
		self: ServiceReplica<Data>,
		path: { string } | string,
		listener: (index: any, new_value: any) -> ()
	) -> ScriptConnection,
	ListenToArrayRemove: (
		self: ServiceReplica<Data>,
		path: { string } | string,
		listener: (old_index: any, old_value: any) -> ()
	) -> ScriptConnection,

	ListenToWrite: (self: ServiceReplica<Data>, function_name: string, listener: (...any) -> ()) -> ScriptConnection,

	ListenToRaw: (
		self: ServiceReplica<Data>,
		listener: (action_name: string, path_array: { any }, ...any) -> ()
	) -> ScriptConnection,
}

-- Controller (Client)
export type ControllerReplica<Data = any> = Replica<Data> & {
	ListenToChange: (
		self: ControllerReplica<Data>,
		path: { string } | string,
		listener: (new_value: any, old_value: any) -> ()
	) -> ScriptConnection,
	ListenToNewKey: (
		self: ControllerReplica<Data>,
		path: { string } | string,
		listener: (new_value: any, new_key: any) -> ()
	) -> ScriptConnection,

	ListenToArrayInsert: (
		self: ControllerReplica<Data>,
		path: { string } | string,
		listener: (new_index: any, new_value: any) -> ()
	) -> ScriptConnection,
	ListenToArraySet: (
		self: ControllerReplica<Data>,
		path: { string } | string,
		listener: (index: any, new_value: any) -> ()
	) -> ScriptConnection,
	ListenToArrayRemove: (
		self: ControllerReplica<Data>,
		path: { string } | string,
		listener: (old_index: any, old_value: any) -> ()
	) -> ScriptConnection,

	ListenToWrite: (
		self: ControllerReplica<Data>,
		function_name: string,
		listener: (...any) -> ()
	) -> ScriptConnection,

	ListenToRaw: (
		self: ControllerReplica<Data>,
		listener: (action_name: string, path_array: { any }, ...any) -> ()
	) -> ScriptConnection,

	ConnectOnClientEvent: (self: ControllerReplica<Data>, listener: (...any) -> ()) -> ScriptConnection,
	FireServer: (self: ControllerReplica<Data>, ...any) -> (),

	ListenToChildAdded: (
		self: ControllerReplica<Data>,
		listener: (replica: ControllerReplica<Data>) -> ()
	) -> ScriptConnection,
	FindFirstChildOfClass: (self: ControllerReplica<Data>, replica_class: string) -> ControllerReplica<Data>?,
}

export type ReplicaClassToken = {
	Class: string,
}

type ReplicaParams = {
	ClassToken: ReplicaClassToken,
	-- Optional params:
	Tags: { [string]: any }?,
	Data: { any }?,
	Replication: ("All" | { [Player]: boolean? } | { Player })?,
	Parent: Replica<any>?,
	WriteLib: ModuleScript?,
}

type ScriptSignal<T... = ...any> = {
	Connect: (
		self: ScriptSignal<T...>,
		listener: (any) -> (),
		disconnect_listener: (() -> ())?,
		disconnect_param: any?
	) -> ScriptConnection,
	GetListenerCount: () -> number,
	Fire: (...any) -> (),
	FireUntil: (continue_callback: () -> (), ...any) -> (),
}

type ScriptConnection = {
	Disconnect: (self: ScriptConnection) -> (),
}

return {}
