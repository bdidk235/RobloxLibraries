-- External Types for ProfileService
export type ProfileService = {
	ServiceLocked: boolean,

	IssueSignal: RBXScriptSignal<string, string, string>,
	CorruptionSignal: RBXScriptSignal<string, string>,
	CriticalStateSignal: RBXScriptSignal<boolean>,

	GetProfileStore: (
		profile_store_index: string | {
			Name: string,
			Scope: string?,
		},
		profile_template: { [string]: any }
	) -> ProfileStore,
	IsLive: () -> boolean?,
}

export type ProfileStore = {
	LoadProfileAsync: (
		self: ProfileStore,
		profile_key: string,
		not_released_handler: (((place_id: number, game_job_id: number) -> string) | "ForceLoad" | "Steal")?,
		_use_mock: {}?
	) -> any?, -- (Profile?)
	GlobalUpdateProfileAsync: (
		profile_key: string,
		update_handler: ((GlobalUpdates) -> ())?,
		_use_mock: {}?
	) -> GlobalUpdates?,
	ViewProfileAsync: (self: ProfileStore, profile_key: string, version: string?, _use_mock: {}?) -> { any }?,
	ProfileVersionQuery: (
		self: ProfileStore,
		profile_key: string,
		sort_direction: Enum.SortDirection,
		min_date: DateTime,
		max_date: DateTime
	) -> ProfileVersionQuery,
	WipeProfileAsync: (self: ProfileStore, profile_key: string) -> boolean,
}

export type ProfileImpl<Data = any> = {
	__index: ProfileImpl<Data>,
	IsActive: (self: Profile<Data>) -> boolean,
	Reconcile: (self: Profile<Data>) -> (),
	ListenToRelease: (self: Profile<Data>, () -> ()) -> (),
	Release: (self: Profile<Data>) -> (),
	ListenToHopReady: (self: Profile<Data>, () -> ()) -> (),
	AddUserId: (self: Profile<Data>, userId: number) -> (),
	RemoveUserId: (self: Profile<Data>, userId: number) -> (),
	Identify: (self: Profile<Data>) -> string,
	SetMetaTag: (self: Profile<Data>, tagName: string, value: any) -> (),
	GetMetaTag: (self: Profile<Data>, tagName: string) -> any,
	Save: (self: Profile<Data>) -> (),
	ClearGlobalUpdates: (self: Profile<Data>) -> (),
	OverwriteAsync: (self: Profile<Data>) -> (),
}

export type ProfileProto<Data = any> = {
	Data: Data,
	MetaData: {
		ProfileCreateTime: number,
		SessionLoadCount: number,
		ActiveSession: { { number }? },
		MetaTags: { [string]: any },
		MetaTagsLatest: { [string]: any },
	},

	MetaTagsUpdated: RBXScriptSignal<{ [string]: any }>,

	RobloxMetaData: { [any]: any },
	UserIds: { number },

	KeyInfo: { DataStoreKeyInfo },
	KeyInfoUpdated: RBXScriptSignal<DataStoreKeyInfo>,

	GlobalUpdates: { any }, -- { GlobalUpdate }
}

export type Profile<Data = any> = typeof(setmetatable({} :: ProfileProto<Data>, {} :: ProfileImpl<Data>))

export type ProfileVersionQuery = {
	ProfileVersionQuery: () -> Profile<any>?,
}

export type GlobalUpdates = {
	GetActiveUpdates: () -> { { any } },
	GetLockedUpdates: () -> { { any } },

	ListenToNewActiveUpdate: (listener: (any) -> (any) -> any) -> RBXScriptConnection,
	ListenToNewLockedUpdate: (listener: (any) -> (any) -> any) -> RBXScriptConnection,
	LockActiveUpdate: (update_id: number) -> (),
	ClearLockedUpdate: (update_id: number) -> (),

	AddActiveUpdate: (update_data: { any }) -> (),
	ChangeActiveUpdate: (update_id: number, update_data: { any }) -> (),
	ClearActiveUpdate: (update_id: number) -> (),
}

return {}
