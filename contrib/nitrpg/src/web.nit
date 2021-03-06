# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2014-2015 Alexandre Terrasa <alexandre@moz-code.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Display `nitrpg` data as a website.
module web

import nitcorn
import templates

# A custom action forn `nitrpg`.
class RpgAction
	super Action

	# Root URL is used as a prefix for all URL generated by the actions.
	var root_url: String

	# Github oauth token used for GithubAPI.
	var auth: String is lazy do return get_github_oauth

	# API client used to import data from Github.
	var api: GithubAPI is lazy do
		var api = new GithubAPI(auth)
		return api
	end

	init do
		super
		if auth.is_empty then
			print "Error: Invalid Github oauth token!"
			exit 1
		end
	end

	# Return an Error reponse page.
	fun bad_request(msg: String): HttpResponse do
		var rsp = new HttpResponse(400)
		var page = new NitRpgPage(root_url)
		var error = new ErrorPanel(msg)
		page.flow_panels.add error
		rsp.body = page.write_to_string
		return rsp
	end

	# Returns the game with `name` or null if no game exists with this name.
	fun load_game(name: String): nullable Game do
		var repo = api.load_repo(name)
		if repo == null then return null
		var game = new Game.from_mongo(api, repo)
		game.root_url = root_url
		return game
	end

	# Returns the list of saved games from NitRPG data.
	fun load_games: Array[Game] do
		var res = new Array[Game]
		# TODO should be option
		var mongo = new MongoClient("mongodb://localhost:27017")
		var db = mongo.database("nitrpg")
		for obj in db.collection("games").find_all(new JsonObject) do
			var repo = api.load_repo(obj["name"].to_s)
			assert repo != null
			var game = new Game(api, repo)
			game.from_json(obj)
			game.root_url = root_url
			res.add game
		end
		return res
	end
end

# Repo overview page.
class RpgHome
	super RpgAction

	# Response page stub.
	var page: NitRpgPage is noinit

	redef fun answer(request, url) do
		var readme = load_readme
		var games = load_games
		var response = new HttpResponse(200)
		page = new NitRpgPage(root_url)
		page.side_panels.add new GamesShortListPanel(root_url, games)
		page.flow_panels.add new MDPanel(readme)
		response.body = page.write_to_string
		return response
	end

	# Load the string content of the nitrpg readme file.
	private fun load_readme: String do
		var readme = "README.md"
		if not readme.file_exists then
			return "Unable to locate README file."
		end
		var file = new FileReader.open(readme)
		var text = file.read_all
		file.close
		return text
	end
end

# Display the list of active game.
class ListGames
	super RpgAction

	# Response page stub.
	var page: NitRpgPage is noinit

	redef fun answer(request, url) do
		var games = load_games
		var response = new HttpResponse(200)
		page = new NitRpgPage(root_url)
		page.breadcrumbs = new Breadcrumbs
		page.breadcrumbs.add_link(root_url / "games", "games")
		page.flow_panels.add new GamesListPanel(root_url, games)
		response.body = page.write_to_string
		return response
	end
end

# An action that require a game.
class GameAction
	super RpgAction

	# Response page stub.
	var page: NitRpgPage is noinit

	# Target game.
	var game: Game is noinit

	redef fun answer(request, url) is abstract

	# Check errors and prepare response.
	private fun prepare_response(request: HttpRequest, url: String): HttpResponse do
		var owner = request.param("owner")
		var repo_name = request.param("repo")
		if owner == null or repo_name == null then
			var msg = "Bad request: should look like /games/:owner/:repo."
			return bad_request(msg)
		end
		var game = load_game("{owner}/{repo_name}")
		if game == null then
			var msg = api.last_error.message
			return bad_request("Repo Error: {msg}")
		end
		self.game = game
		var response = new HttpResponse(200)
		page = new NitRpgPage(root_url)
		page.side_panels.add new GameStatusPanel(game)
		page.breadcrumbs = new Breadcrumbs
		page.breadcrumbs.add_link(game.url, game.name)
		prepare_pagination(request)
		return response
	end

	# Parse pagination related parameters.
	private fun prepare_pagination(request: HttpRequest) do
		var args = request.get_args
		list_from = args.get_or_default("pfrom", "0").to_i
		list_limit = args.get_or_default("plimit", "10").to_i
	end

	# Limit of events to display in lists.
	var list_limit = 10

	# From where to start the display of events related lists.
	var list_from = 0

	# TODO should also check 201, 203 ...
	private fun is_response_error(response: HttpResponse): Bool do
		return response.status_code != 200
	end
end

# Repo overview page.
class RepoHome
	super GameAction

	redef fun answer(request, url) do
		var rsp = prepare_response(request, url)
		if is_response_error(rsp) then return rsp
		page.side_panels.add new ShortListPlayersPanel(game)
		page.flow_panels.add new PodiumPanel(game)
		page.flow_panels.add new EventListPanel(game, list_limit, list_from)
		page.flow_panels.add new AchievementsListPanel(game)
		rsp.body = page.write_to_string
		return rsp
	end
end

# Repo players list.
class ListPlayers
	super GameAction

	redef fun answer(request, url) do
		var rsp = prepare_response(request, url)
		if is_response_error(rsp) then return rsp
		page.breadcrumbs.add_link(game.url / "players", "players")
		page.flow_panels.add new ListPlayersPanel(game)
		rsp.body = page.write_to_string
		return rsp
	end
end

# Player details page.
class PlayerHome
	super GameAction

	redef fun answer(request, url) do
		var rsp = prepare_response(request, url)
		if is_response_error(rsp) then return rsp
		var name = request.param("player")
		if name == null then
			var msg = "Bad request: should look like /:owner/:repo/:players/:name."
			return bad_request(msg)
		end
		var player = game.load_player(name)
		if player == null then
			return bad_request("Request Error: unknown player {name}.")
		end
		page.breadcrumbs.add_link(game.url / "players", "players")
		page.breadcrumbs.add_link(player.url, name)
		page.side_panels.clear
		page.side_panels.add new PlayerStatusPanel(game, player)
		page.flow_panels.add new PlayerReviewsPanel(game, player)
		page.flow_panels.add new PlayerWorkPanel(game, player)
		page.flow_panels.add new AchievementsListPanel(player)
		page.flow_panels.add new EventListPanel(player, list_limit, list_from)
		rsp.body = page.write_to_string
		return rsp
	end
end

# Display the list of achievements unlocked for this game.
class ListAchievements
	super GameAction

	redef fun answer(request, url) do
		var rsp = prepare_response(request, url)
		if is_response_error(rsp) then return rsp
		page.breadcrumbs.add_link(game.url / "achievements", "achievements")
		page.flow_panels.add new AchievementsListPanel(game)
		rsp.body = page.write_to_string
		return rsp
	end
end

# Player details page.
class AchievementHome
	super GameAction

	redef fun answer(request, url) do
		var rsp = prepare_response(request, url)
		if is_response_error(rsp) then return rsp
		var name = request.param("achievement")
		if name == null then
			var msg = "Bad request: should look like /:owner/:repo/achievements/:achievement."
			return bad_request(msg)
		end
		var achievement = game.load_achievement(name)
		if achievement == null then
			return bad_request("Request Error: unknown achievement {name}.")
		end
		page.breadcrumbs.add_link(game.url / "achievements", "achievements")
		page.breadcrumbs.add_link(achievement.url, achievement.name)
		page.flow_panels.add new AchievementPanel(achievement)
		page.flow_panels.add new EventListPanel(achievement, list_limit, list_from)
		rsp.body = page.write_to_string
		return rsp
	end
end

if args.length != 3 then
	print "Error: missing argument"
	print ""
	print "Usage:"
	print "web <host> <port> <root_url>"
	exit 1
end

var host = args[0]
var port = args[1]
var root = args[2]

var iface = "{host}:{port}"
var vh = new VirtualHost(iface)
vh.routes.add new Route("/styles/", new FileServer("www/styles"))
vh.routes.add new Route("/games/:owner/:repo/players/:player", new PlayerHome(root))
vh.routes.add new Route("/games/:owner/:repo/players", new ListPlayers(root))
vh.routes.add new Route("/games/:owner/:repo/achievements/:achievement", new AchievementHome(root))
vh.routes.add new Route("/games/:owner/:repo/achievements", new ListAchievements(root))
vh.routes.add new Route("/games/:owner/:repo", new RepoHome(root))
vh.routes.add new Route("/games", new ListGames(root))
vh.routes.add new Route("/", new RpgHome(root))

var fac = new HttpFactory.and_libevent
fac.config.virtual_hosts.add vh

print "Launching server on http://{iface}/"
fac.run
