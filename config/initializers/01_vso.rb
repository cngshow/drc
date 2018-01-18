require './lib/util/helpers'


# WebNotificationsChannel.broadcast_to(
#     current_user,
#     title: 'New things!',
#     body: 'All the news fit to print'
# )

#
# # Somewhere in your app this is called, perhaps
# # from a NewCommentJob.
# ActionCable.server.broadcast(
#     "chat_#{room}",
#     sent_by: 'Paul',
#     body: 'This is a cool chat app.'
# )