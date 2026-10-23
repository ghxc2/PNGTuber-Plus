extends Gift

const REDEMPTIONS_PATH = Global.REDEMPTIONS_PATH
var redemptions = Global.redemptions
@onready var queue: Node2D = $"../CostumeQueue"

func _ready() -> void:
	events_connected.connect(func():
		print("[GIFT] EventSub connected")
	)
	events_disconnected.connect(func():
		print("[GIFT] WARNING: EventSub disconnected")
	)
	events_unavailable.connect(func():
		print("[GIFT] ERROR: EventSub unavailable")
	)
	events_reconnect.connect(func():
		print("[GIFT] EventSub reconnect requested")
	)
	events_revoked.connect(func(event_name, reason):
		print("[GIFT] Subscription revoked: ", event_name, " | ", reason)
	)
	
	
	
	load_redemptions()
	event.connect(on_event)

	# Tell GIFT what Twitch permissions needed
	scopes = ["channel:read:redemptions"]
	
	# Load Twitch authentication information
	var authfile := FileAccess.open("user://auth.txt", FileAccess.READ)

	client_id = authfile.get_line()
	client_secret = authfile.get_line()
	var initial_channel = authfile.get_line()

	# Authenticate with Twitch
	await authenticate(client_id, client_secret)

	# Connect to EventSub
	await connect_to_eventsub()

	# Listen for Channel Point redemptions
	subscribe_event(
		"channel.channel_points_custom_reward_redemption.add",
		1,
		{
			"broadcaster_user_id": user_id
		}
	)

func on_event(type: String, data: Dictionary) -> void:
	match type:
		"channel.channel_points_custom_reward_redemption.add":
			var reward_name: String = data["reward"]["title"]
			var user: String = data["user_name"]
			
			
			#print(user, " redeemed ", reward_name)
			
			if not Global.redemptions.has(reward_name):
				return
			#var file_path: String = redemptions.get(reward_name, "")
			#
			#print(file_path)
			#
			#if file_path.is_empty():
				#print("error")
				#return
			
			queue.enqueue(reward_name)
			#queue.print_queue()
			
func load_redemptions() -> void:
	if not FileAccess.file_exists(REDEMPTIONS_PATH):
		print("No redemption configuration found.")
		return

	var file := FileAccess.open(REDEMPTIONS_PATH, FileAccess.READ)

	if file == null:
		print("Failed to open redemption configuration.")
		return

	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if data is Dictionary:
		redemptions.merge(data)
		print("Loaded redemptions: ", redemptions)
	
