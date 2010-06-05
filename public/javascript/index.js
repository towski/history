var EventListItem = Class.extend({
  init: function(event) {
    this.event = event;
  },

  toLi: function(){
    var li = $(document.createElement('li'))
    li.html("\
    <div> \
      <fb:profile-pic uid='"+this.event.actor_id+"'/> \
    </div> \
    <div> \
      <fb:name uid='"+this.event.actor_id+"'/>"+this.event.message+" \
    </div>");
    return li;
  }
})

var History = Class.extend({
  init: function(user_id, friend_id) {
    this.user_id = user_id;
    this.friend_id = friend_id;
  },

  getUserFriendHistory: function(callback){
    $.getJSON('/history/'+this.user_id+"/"+this.friend_id, callback)
  },

  getFriendUserHistory: function(callback){
    $.getJSON('/history/'+this.friend_id+"/"+this.user_id, callback)
  },

  addHistory: function(events){
    events = $(events)
    events.each(function(index, event){
      var li = new EventListItem(event)
      $('ul#history').append(li.toLi());
    });
  },

  run: function(){
    this.getUserFriendHistory(this.addHistory)
    this.getFriendUserHistory(this.addHistory)
  }
});

$(document).ready(function(){
  var ul = $(document.createElement('ul'))
  ul.attr('id','history')
  $('body').append(ul)
});
