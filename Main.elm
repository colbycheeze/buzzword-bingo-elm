module Main where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

import StartApp.Simple as StartApp
import Signal exposing (Address)
import Debug

import BingoUtils exposing (onInput, parseInt)

-- MODEL

type alias Entry =
  { phrase : String
  , points : Int
  , wasSpoken : Bool
  , id : Int
  }

type alias Model =
  { entries : List Entry
  , phraseInput : String
  , pointsInput : String
  , nextID : ID
  }


init : Model
init =
    { entries =
      [ Entry "Doing Agile" 200 False 2
      , Entry "In The Cloud" 300 False 3
      , Entry "Future-Proof" 100 False 1
      , Entry "Rock-Star Ninja" 400 False 4
      ]
    , phraseInput = ""
    , pointsInput = ""
    , nextID = 5
    }

-- UPDATE

type Action
  = NoOp
  | Sort
  | Delete ID
  | Mark ID
  | UpdatePhraseInput String
  | UpdatePointsInput String
  | Add

type alias ID = Int

update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    Add ->
      let entryToAdd = Entry model.phraseInput (parseInt model.pointsInput) False model.nextID
          isInvalid model =
            String.isEmpty model.phraseInput || String.isEmpty model.pointsInput
      in
          if isInvalid model then model
          else
          { model |
              entries =  entryToAdd :: model.entries,
              nextID = model.nextID + 1,
              phraseInput = "",
              pointsInput = ""
          }

    UpdatePhraseInput  contents ->
      { model | phraseInput = contents }

    UpdatePointsInput  contents ->
      { model | pointsInput = contents }

    Mark id ->
      let updateEntry e =
            if e.id == id then { e | wasSpoken = (not e.wasSpoken) } else e
      in
          { model | entries = List.map updateEntry model.entries }

    Sort ->
      { model | entries = List.sortBy .points model.entries }

    Delete id ->
      let remainingEntries =
            List.filter (\entry -> entry.id /= id) model.entries
      in
          { model | entries = remainingEntries  }

-- VIEW

title : String -> Int -> Html
title message times =
  message ++ " "
    |> String.toUpper
    |> String.repeat times
    |> String.trimRight
    |> text


pageHeader : Html
pageHeader =
  h1 [ ] [ text "Buzzword Bingo!" ]

pageFooter : Html
pageFooter =
  footer []
    [ a [ href "http://colbycheeze.com", target "_blank" ]
        [ text "ColbyCheeZe Blog" ]
    ]

entryItem : Address Action -> Entry -> Html
entryItem address entry =
  li [ classList
    [ ("highlight", entry.wasSpoken) ]
    , onClick address (Mark entry.id)
    ]
    [ button [ class "delete", onClick address (Delete entry.id) ] []
    , span [ class "phrase" ] [ text entry.phrase ]
    , span [ class "points" ] [ text (toString entry.points) ]
    ]

totalPoints : List Entry -> Int
totalPoints entries =
      entries
        |> List.filter .wasSpoken
        |> List.foldl (\entry sum -> sum + entry.points) 0

totalItem : Int -> Html
totalItem total =
  li [ class "total" ]
  [ span [ class "label" ] [ text "Total" ]
  , span [ class "points" ] [ text (toString total) ]
  ]

entryList : Address Action -> List Entry -> Html
entryList address entries =
  let entryItems = List.map (entryItem address) entries
      items = entryItems ++ [ totalItem (totalPoints entries) ]
  in
      ul [] items

isEnter : Int -> Action
isEnter code =
  if code == 13 then Add else NoOp

entryForm : Address Action -> Model -> Html
entryForm address model =
  div
    []
    [ input
      [ type' "text"
      , placeholder "Phrase"
      , value model.phraseInput
      , name "phrase"
      , autofocus True
      , onInput address UpdatePhraseInput
      , onKeyPress address isEnter
      ]
      []
    , input
      [ type' "number"
      , placeholder "Points"
      , value model.pointsInput
      , name "points"
      , onInput address UpdatePointsInput
      , onKeyPress address isEnter
      ]
      []
    , button
      [ class "add", onClick address Add, onKeyPress address isEnter ]
      [ text "Add" ]
    , h2
      []
      [ text (model.phraseInput ++ " " ++ model.pointsInput) ]
    ]

view : Address Action -> Model -> Html
view address model =
  div [ id "container" ]
    [ pageHeader
    , entryForm address model
    , entryList address model.entries
    , button [ class "sort", onClick address Sort ] [ text "Sort" ]
    , pageFooter
    ]

main : Signal Html
main =
  StartApp.start
    { model = init
    , view = view
    , update = update
    }
