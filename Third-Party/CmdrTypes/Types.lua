-- External Types for Cmdr
-- Types taken from https://github.com/TheNexusAvenger/Nexus-Admin/blob/master/src/Types.lua
export type CmdrArgumentContext = {
	Command: CmdrCommandContext,
	Name: string,
	Type: CmdrTypeDefinition<any>,
	Required: boolean,
	Executor: Player,
	RawValue: string,
	RawSegments: { string },
	Prefix: string,

	GetValue: (self: CmdrArgumentContext) -> any,
	GetTransformedValue: (self: CmdrArgumentContext, Segment: number) -> ...any,
}

export type CmdrCommandContext = {
	Dispatcher: CmdrDispatcher,
	Name: string,
	Alias: string,
	RawText: string,
	Group: string,
	State: { [any]: any },
	Aliases: { string },
	Description: string,
	Executor: Player,
	RawArguments: { string },
	Arguments: { CmdrArgumentContext },
	Response: string?,

	GetArgument: (self: CmdrCommandContext, number) -> CmdrArgumentContext,
	GetData: (self: CmdrCommandContext) -> any,
	GetStore: (self: CmdrCommandContext, name: string) -> { [any]: any },
	SendEvent: (self: CmdrCommandContext, Player: Player, Event: string) -> (),
	BroadcastEvent: (self: CmdrCommandContext, Evnet: string, ...any) -> (),
	Reply: (self: CmdrCommandContext, Text: string, Color: Color3?) -> (),
	HasImplementation: (self: CmdrCommandContext) -> boolean,
}

export type CmdrServerCommandContext = CmdrCommandContext & {
	Cmdr: Cmdr,
}

export type CmdrClientCommandContext = CmdrCommandContext & {
	Cmdr: CmdrClient,
}

export type CmdrTypeDefinition<T> = {
	DisplayName: string?,
	Prefixes: string?,
	Transform: ((RawText: string, Exeuctor: Player) -> T)?,
	Validate: ((Value: T) -> (boolean, string?))?,
	ValidateOnce: ((Value: T) -> (boolean, string?))?,
	Autocomplete: ((Value: T) -> ({ string }, { IsPartial: boolean? }?))?,
	Parse: (Value: T) -> any,
	Default: ((Player: Player) -> string?)?,
	Listable: boolean?,
}

export type CmdrCommandArgument = {
	Type: string | CmdrTypeDefinition<any>,
	Name: string,
	Description: string,
	Optional: boolean?,
	Default: any?,
}

export type CmdrCommandDefinition = {
	Name: string,
	Aliases: { string },
	Description: string,
	Group: string?,
	Args: { CmdrCommandArgument | (Context: CmdrClientCommandContext) -> CmdrCommandArgument },
	Data: ((Context: CmdrClientCommandContext, ...any) -> any)?,
	ClientRun: ((Context: CmdrClientCommandContext, ...any) -> any)?,
	AutoExec: { string }?,
}

export type CmdrRegistry = {
	Cmdr: Cmdr,
	RegisterTypesIn: (self: CmdrRegistry, Container: Instance) -> (),
	RegisterType: <T>(self: CmdrRegistry, Name: string, TypeDefinition: CmdrTypeDefinition<T>) -> (),
	RegisterTypePrefix: (self: CmdrRegistry, Name: string, Union: string) -> (),
	RegisterTypeAlias: (self: CmdrRegistry, Name: string, Union: string) -> (),
	GetType: (self: CmdrRegistry, Name: string) -> CmdrTypeDefinition<any>?,
	GetTypeName: (self: CmdrRegistry, Name: string) -> string,
	RegisterHooksIn: (self: CmdrRegistry, Container: Instance) -> (),
	RegisterCommandsIn: (
		self: CmdrRegistry,
		Container: Instance,
		Filter: ((Command: CmdrCommandDefinition) -> boolean)?
	) -> (),
	RegisterCommand: (
		self: CmdrRegistry,
		CommandScript: ModuleScript,
		CommandServerScript: ModuleScript?,
		Filter: ((Command: CmdrCommandDefinition) -> boolean)?
	) -> (),
	RegisterDefaultCommands: (self: CmdrRegistry, ({ string } | (Command: CmdrCommandDefinition) -> boolean)?) -> (),
	GetCommand: (self: CmdrRegistry, Name: string) -> CmdrCommandDefinition?,
	GetCommands: (self: CmdrRegistry) -> { CmdrCommandDefinition },
	GetCommandNames: (self: CmdrRegistry) -> { string },
	RegisterHook: (
		self: CmdrRegistry,
		HookName: "BeforeRun" | "AfterRun",
		Callback: (Context: CmdrServerCommandContext) -> string?,
		Priority: number?
	) -> (),
	GetStore: (self: CmdrRegistry, Name: string) -> { [any]: any },
}

export type CmdrDispatcher = {
	Cmdr: Cmdr,
	Run: (self: CmdrDispatcher, ...string) -> string,
	EvaluateAndRun: (
		self: CmdrDispatcher,
		CommandText: string,
		Executor: Player?,
		Options: { Data: any?, IsHuman: boolean }?
	) -> string,
	GetHistory: (self: CmdrDispatcher) -> { string },
}

export type CmdrUtil = {
	Cmdr: Cmdr,
	MakeDictionary: <T>(Array: { T }) -> { [T]: true },
	Map: <T, U>(Array: { T }, Mapper: (Value: T, Index: number) -> U) -> { U },
	Each: <T, U>(Mapper: (Value: T) -> U, ...T) -> ...U,
	MakeFuzzyFinder: (
		Set: { string } | { Instance } | { Enum } | { { Name: string } } | Instance
	) -> (Text: string, ReturnFirst: boolean?) -> any,
	GetNames: (Instances: { { Name: string } }) -> { string },
	SplitStringSimple: (Text: string, Separator: string) -> { string },
	SplitString: (Text: string, Max: number?) -> { string },
	TrimString: (Text: string) -> string,
	GetTextSize: (Text: string, Label: TextLabel, Size: Vector2?) -> Vector2,
	MakeEnumType: <T>(Type: string, Values: { string | { { Name: string } } }) -> CmdrTypeDefinition<T>,
	MakeListableType: <T>(Type: CmdrTypeDefinition<T>, Override: { [any]: string }?) -> CmdrTypeDefinition<T>,
	SplitPrioritizedDelimeter: (Text: string, Delimeters: { string }) -> { string },
	SubstituteArgs: (Text: string, Replace: { string } | { [string]: string } | (Var: string) -> string) -> string,
	RunEmbeddedCommands: (Dispatcher: CmdrDispatcher, CommandString: string) -> string,
	EmulateTabstops: (Text: string, TabWidth: number) -> string,
	ParseEscapeSequences: (Text: string) -> string,
}

export type Cmdr = {
	Registry: CmdrRegistry,
	Dispatcher: CmdrDispatcher,
	Util: CmdrUtil,
}

export type CmdrClient = Cmdr & {
	Enabled: boolean,
	PlaceName: string,
	ActivationKeys: { Enum.KeyCode },
	SetActivationKeys: (self: CmdrClient, keys: { Enum.KeyCode }) -> (),
	SetPlaceName: (self: CmdrClient, labelText: string) -> (),
	SetEnabled: (self: CmdrClient, isEnabled: boolean) -> (),
	Show: (self: CmdrClient) -> (),
	Hide: (self: CmdrClient) -> (),
	Toggle: (self: CmdrClient) -> (),
	HandleEvent: (self: CmdrClient, event: string, handler: (...any?) -> ()) -> (),
	SetMashToEnable: (iself: CmdrClient, sEnabled: boolean) -> (),
	SetActivationUnlocksMouse: (self: CmdrClient, isEnabled: boolean) -> (),
	SetHideOnLostFocus: (self: CmdrClient, isEnabled: boolean) -> (),
}

return {}
