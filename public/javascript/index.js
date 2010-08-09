var parsePictures = function(){
  if(typeof(disableXFBML) == "undefined"){
    FB.XFBML.parse($('ul').get(0))
  }
};

var eventToLi = function(event){
  var li = $(document.createElement('li'))
  var div = $(document.createElement('fb:profile-pic'))
  li.attr("created_time", event.created_time)
  li.attr("post_id", event.post_id)
  li.attr("class", "event")
  div.attr("uid", event.actor_id)
  div.attr("size", "square")
  li.append(div)
  var commentsUl = $(document.createElement('ul'))
  if(event.comments && event.comments.count > 0){
    $(event.comments.comment_list).each(function(index, comment){
      commentsUl.append("<li><fb:profile-pic uid='"+ comment.fromid +"' size='square' width='25px' height='25px'></fb:profile-pic>&nbsp;"+comment.text+"</li>")
    });
  }
  var attachmentDiv = $(document.createElement('div'))
  var attachment = event.attachment
  if(attachment && attachment.description && attachment.description != ""){
    var media = attachment.media[0];
    if(media && media.type == "photo"){
      attachmentDiv.append("<a href='"+media.href+"'><img src='"+media.src+"'/></a>")
    }
    attachmentDiv.append("<br/> "+attachment.description)
    li.append(attachmentDiv)
  }
  li.append(event.message ? event.message : event.text)
  li.append(commentsUl)
  return li;
}

var History = Class.extend({
  init: function(friend_id, user_id, disableXFBML) {
    this.friend_id = friend_id;
    this.user_id = user_id;
  },

  getUserFriendHistory: function(callback){
    $.getJSON('/history/'+this.friend_id+'/'+this.user_id, function(events){ callback(events); $('#loading').hide(); parsePictures()  })
  },

  getFriendUserHistory: function(callback){
    $.getJSON('/history/'+this.user_id+'/'+this.friend_id, function(events){ callback(events); $('#loading_friends').hide(); parsePictures() })
  },

  getComments: function(callback){
    $.getJSON("/comments/"+this.user_id+"/"+this.friend_id, function(events){ glob = events; callback(events); $('#loading_comments').hide(); parsePictures() })
  },

  getFriendsComments: function(callback){
    $.getJSON("/comments/"+this.friend_id+"/"+this.user_id, function(events){ callback(events); $('#loading_friends_comments').hide(); parsePictures() })
  },

  addHistory: function(events){
    var list = $("ul#history li")
    $(events).each(function(index, event){
      var eventPlaced = false;
      if(list.length == 0){
        $("ul#history").append(eventToLi(event));
      } else{
        while(!eventPlaced){
          var head = $(list[0])
          if(head == null || list.length == 0){
            $("ul#history").append(eventToLi(event));
            eventPlaced = true;
          }else if(head.attr('created_time') < event.created_time){
            head.before(eventToLi(event));
            eventPlaced = true;
          }else{
            list.splice(0,1)
          }
        }
      }
    });
  },

  addComments: function(comments){
    $(comments).each(function(index, comment){
      var li = $('li[post_id='+comment.post_id+']')[0];
      if(typeof(li) == "undefined"){
        var added;
        $("ul#history li").each(function(index, li){
          if(!added && $(li).attr('created_time') < comment.post.created_time){
            $(li).before(eventToLi(comment.post));
            added = true;
          }
        })
        //if(!added){
        //  $("ul#history").append(eventToLi(comment.post));
        //}
      }
    });
    //[{"post_id"=>"702502119_400073052119", "text"=>"Damn DUDE!", "time"=>1275021333, "fromid"=>692791726}]
  },

  run: function(){
    this.getUserFriendHistory(this.addHistory)
    this.getFriendUserHistory(this.addHistory)
    this.getComments(this.addComments)
    this.getFriendsComments(this.addComments)
  }
});

$().ready(function() {
  setFacebookPic = function(id){
    FB.XFBML.parse($("#item"+id).get(0)); 
  };
  var options = {
    width: 320,
    max: 4,
    highlight: false,
    scroll: true,
    scrollHeight: 300,
    formatItem: function(data, i, n, value) {
      setTimeout('setFacebookPic('+data[1]+');', 10);
      return '<div id="item'+data[1]+'" class="searchResult"><fb:profile-pic id="pic'+data[1]+'" class="profilePic" uid="'+data[1]+'" size="square"></div><div class="name"> &nbsp;'+value+'</div></div>'
    },
    formatResult: function(data, value) {
      return value.split(".")[0];
    }
  }
  $("#friends").autocomplete("friends", options).result(function(e, item) {
    $('.loading').show();
    var history = new History(facebookId, item[1])
    history.run()
    $('.event').remove();
  });
  $("#friend1").autocomplete("friends", options).result(function(e, item) {
    $('#hiddenId').attr('value',item[1])
  });
  $("#friend2").autocomplete("friends", options).result(function(e, item) {
    $('.loading').show();
    var history = new History(item[1], $('#hiddenId').attr('value'))
    history.run()
    $('.event').remove();
  });
});
